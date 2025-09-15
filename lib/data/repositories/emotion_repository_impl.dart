import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/emotion_log.dart';
import '../../data/services/firestore_service.dart';
import '../../data/services/health_platform_service.dart';
import '../repositories/emotion_repository.dart';

/// Implementation of EmotionRepository using Firestore and health platforms
class EmotionRepositoryImpl implements EmotionRepository {
  final FirestoreService _firestoreService;
  final HealthPlatformService _healthPlatformService;

  static const String _collectionPath = 'emotion_logs';

  EmotionRepositoryImpl(
    this._firestoreService,
    this._healthPlatformService,
  );

  @override
  Future<void> addEmotionLog(EmotionLog log) async {
    try {
      // Generate ID if not provided
      final logWithId = log.id.isEmpty
          ? log.copyWith(id: _generateId())
          : log;

      // Save to Firestore
      await _firestoreService.setDocument(
        '$_collectionPath/${logWithId.id}',
        _emotionLogToFirestore(logWithId),
      );

      // Save to health platform if authorized
      final hasHealthAuth = await _healthPlatformService.hasAuthorization();
      if (hasHealthAuth) {
        await _healthPlatformService.writeEmotionLog(logWithId);
      }
    } catch (e) {
      throw Exception('Failed to save emotion log: $e');
    }
  }

  @override
  Future<List<EmotionLog>> getEmotionLogs(String userId, {int? limit}) async {
    try {
      final querySnapshot = await _firestoreService.getCollectionWhere(
        _collectionPath,
        field: 'userId',
        value: userId,
        orderBy: 'timestamp',
        descending: true,
        limit: limit,
      );

      return querySnapshot.docs
          .map((doc) => _emotionLogFromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get emotion logs: $e');
    }
  }

  @override
  Future<List<EmotionLog>> getRecentEmotionLogs(
    String userId, {
    int days = 7,
    int? limit,
  }) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: days));
      
      final whereClauses = [
        WhereClause(field: 'userId', isEqualTo: userId),
        WhereClause(field: 'timestamp', isGreaterThanOrEqualTo: cutoffDate),
      ];

      final querySnapshot = await _firestoreService.getCollectionWhereMultiple(
        _collectionPath,
        whereClauses: whereClauses,
        orderBy: 'timestamp',
        descending: true,
        limit: limit,
      );

      return querySnapshot.docs
          .map((doc) => _emotionLogFromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get recent emotion logs: $e');
    }
  }

  @override
  Future<void> updateEmotionLog(EmotionLog log) async {
    try {
      await _firestoreService.updateDocument(
        '$_collectionPath/${log.id}',
        _emotionLogToFirestore(log.copyWith(updatedAt: DateTime.now())),
      );
    } catch (e) {
      throw Exception('Failed to update emotion log: $e');
    }
  }

  @override
  Future<void> deleteEmotionLog(String logId) async {
    try {
      await _firestoreService.deleteDocument('$_collectionPath/$logId');
    } catch (e) {
      throw Exception('Failed to delete emotion log: $e');
    }
  }

  @override
  Future<List<EmotionLog>> getEmotionLogsByMood(
    String userId,
    String mood, {
    int? limit,
  }) async {
    try {
      final whereClauses = [
        WhereClause(field: 'userId', isEqualTo: userId),
        WhereClause(field: 'mood', isEqualTo: mood.toLowerCase()),
      ];

      final querySnapshot = await _firestoreService.getCollectionWhereMultiple(
        _collectionPath,
        whereClauses: whereClauses,
        orderBy: 'timestamp',
        descending: true,
        limit: limit,
      );

      return querySnapshot.docs
          .map((doc) => _emotionLogFromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get emotion logs by mood: $e');
    }
  }

  @override
  Future<List<EmotionLog>> getEmotionLogsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final whereClauses = [
        WhereClause(field: 'userId', isEqualTo: userId),
        WhereClause(field: 'timestamp', isGreaterThanOrEqualTo: startDate),
        WhereClause(field: 'timestamp', isLessThanOrEqualTo: endDate),
      ];

      final querySnapshot = await _firestoreService.getCollectionWhereMultiple(
        _collectionPath,
        whereClauses: whereClauses,
        orderBy: 'timestamp',
        descending: false,
      );

      return querySnapshot.docs
          .map((doc) => _emotionLogFromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get emotion logs by date range: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getEmotionStatistics(String userId) async {
    try {
      // Get logs from last 30 days
      final logs = await getRecentEmotionLogs(userId, days: 30);
      
      if (logs.isEmpty) {
        return {
          'totalLogs': 0,
          'averageIntensity': 0.0,
          'moodDistribution': <String, int>{},
          'lastLogDate': null,
          'streakDays': 0,
        };
      }

      // Calculate statistics
      final totalLogs = logs.length;
      final averageIntensity = logs.fold<double>(
        0.0,
        (sum, log) => sum + log.intensity,
      ) / totalLogs;

      // Mood distribution
      final moodDistribution = <String, int>{};
      for (final log in logs) {
        moodDistribution[log.mood] = (moodDistribution[log.mood] ?? 0) + 1;
      }

      // Calculate streak (consecutive days with logs)
      final streakDays = _calculateStreakDays(logs);

      return {
        'totalLogs': totalLogs,
        'averageIntensity': averageIntensity,
        'moodDistribution': moodDistribution,
        'lastLogDate': logs.first.timestamp.toIso8601String(),
        'streakDays': streakDays,
      };
    } catch (e) {
      throw Exception('Failed to get emotion statistics: $e');
    }
  }

  /// Calculate consecutive days with emotion logs
  int _calculateStreakDays(List<EmotionLog> logs) {
    if (logs.isEmpty) return 0;

    final sortedLogs = List<EmotionLog>.from(logs)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final today = DateTime.now();
    final logDates = sortedLogs
        .map((log) => DateTime(
              log.timestamp.year,
              log.timestamp.month,
              log.timestamp.day,
            ))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime currentDate = DateTime(today.year, today.month, today.day);

    for (final logDate in logDates) {
      if (logDate.isAtSameMomentAs(currentDate) ||
          logDate.isAtSameMomentAs(currentDate.subtract(const Duration(days: 1)))) {
        streak++;
        currentDate = logDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  /// Convert EmotionLog to Firestore format
  Map<String, dynamic> _emotionLogToFirestore(EmotionLog log) {
    final data = log.toJson();
    // Convert DateTime to Timestamp for Firestore
    data['timestamp'] = Timestamp.fromDate(log.timestamp);
    if (log.metadata != null) {
      data['updatedAt'] = Timestamp.fromDate(DateTime.now());
    }
    return data;
  }

  /// Convert Firestore data to EmotionLog
  EmotionLog _emotionLogFromFirestore(Map<String, dynamic> data, String id) {
    // Convert Timestamp back to DateTime
    final timestamp = (data['timestamp'] as Timestamp).toDate();
    data['timestamp'] = timestamp.toIso8601String();
    data['id'] = id;
    
    return EmotionLog.fromJson(data);
  }

  /// Generate unique ID for emotion log
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}