import 'package:flutter/material.dart';
import '../../domain/models/emotion_log.dart';
import 'emotion_log_screen.dart';

/// View model for emotion log analytics and filtering
class EmotionLogViewModel extends ChangeNotifier {
  List<EmotionLog> _allLogs = [];
  List<EmotionLog> _filteredLogs = [];
  TimePeriod _selectedPeriod = TimePeriod.week;
  bool _isLoading = false;

  // Getters
  List<EmotionLog> get allLogs => _allLogs;
  List<EmotionLog> get filteredLogs => _filteredLogs;
  TimePeriod get selectedPeriod => _selectedPeriod;
  bool get isLoading => _isLoading;

  /// Load emotion logs (mock data for now)
  Future<void> loadEmotionLogs() async {
    _isLoading = true;
    notifyListeners();

    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Generate mock data for demonstration
    _allLogs = _generateMockData();
    _filterLogsByPeriod();

    _isLoading = false;
    notifyListeners();
  }

  /// Set time period filter
  void setTimePeriod(TimePeriod period) {
    _selectedPeriod = period;
    _filterLogsByPeriod();
    notifyListeners();
  }

  /// Filter logs by selected time period
  void _filterLogsByPeriod() {
    final now = DateTime.now();
    DateTime cutoffDate;

    switch (_selectedPeriod) {
      case TimePeriod.day:
        cutoffDate = now.subtract(const Duration(days: 1));
        break;
      case TimePeriod.week:
        cutoffDate = now.subtract(const Duration(days: 7));
        break;
      case TimePeriod.month:
        cutoffDate = now.subtract(const Duration(days: 30));
        break;
      case TimePeriod.sixMonths:
        cutoffDate = now.subtract(const Duration(days: 180));
        break;
      case TimePeriod.year:
        cutoffDate = now.subtract(const Duration(days: 365));
        break;
    }

    _filteredLogs = _allLogs.where((log) => log.timestamp.isAfter(cutoffDate)).toList();
    _filteredLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Get association counts for pie chart
  Map<String, int> getAssociationCounts() {
    final counts = <String, int>{};
    
    for (final log in _filteredLogs) {
      final association = 'General'; // Since we don't have associations in current model
      counts[association] = (counts[association] ?? 0) + 1;
    }
    
    return counts;
  }

  /// Generate mock data for demonstration
  List<EmotionLog> _generateMockData() {
    final moods = ['happy', 'sad', 'anxious', 'calm', 'excited', 'frustrated', 'peaceful'];
    final notes = [
      'Had a great day at work',
      'Feeling overwhelmed with tasks',
      'Enjoyed time with family',
      'Worried about upcoming presentation',
      'Peaceful morning meditation',
      'Excited about weekend plans',
      'Feeling grateful for support',
    ];

    final logs = <EmotionLog>[];
    final now = DateTime.now();

    // Generate 50 mock entries over the past 6 months
    for (int i = 0; i < 50; i++) {
      final daysBack = (i * 3.6).round(); // Roughly every 3-4 days
      final timestamp = now.subtract(Duration(days: daysBack));
      
      final mood = moods[i % moods.length];
      final intensity = (i % 5) + 1;
      final note = i % 3 == 0 ? notes[i % notes.length] : null;

      logs.add(
        EmotionLog(
          id: 'log_$i',
          timestamp: timestamp,
          mood: mood,
          intensity: intensity,
          note: note,
          userId: 'mock_user',
          type: EmotionLogType.manual,
        ),
      );
    }

    return logs;
  }

  /// Refresh data
  Future<void> refresh() async {
    await loadEmotionLogs();
  }
}