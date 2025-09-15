import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/models/emotion_log.dart';
import '../../data/services/firestore_service.dart';
import '../repositories/user_repository.dart';

/// Implementation of UserRepository using Firestore
class UserRepositoryImpl implements UserRepository {
  final FirestoreService _firestoreService;

  static const String _usersCollection = 'users';
  static const String _emotionLogsCollection = 'emotion_logs';

  UserRepositoryImpl(this._firestoreService);

  @override
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final doc = await _firestoreService.getDocument('$_usersCollection/$userId');
      
      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return _userProfileFromFirestore(doc.data()!, userId);
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  @override
  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      await _firestoreService.setDocument(
        '$_usersCollection/${profile.uid}',
        _userProfileToFirestore(profile),
        merge: true,
      );
    } catch (e) {
      throw Exception('Failed to save user profile: $e');
    }
  }

  @override
  Future<void> updateUserProfile(String userId, Map<String, dynamic> updates) async {
    try {
      // Add updatedAt timestamp
      final updatesWithTimestamp = {
        ...updates,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      await _firestoreService.updateDocument(
        '$_usersCollection/$userId',
        updatesWithTimestamp,
      );
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  @override
  Future<void> deleteUserProfile(String userId) async {
    try {
      // Note: In a real app, you might want to soft delete or archive user data
      await _firestoreService.deleteDocument('$_usersCollection/$userId');
    } catch (e) {
      throw Exception('Failed to delete user profile: $e');
    }
  }

  @override
  Future<List<EmotionLog>> getRecentEmotionLogs(String userId, {int limit = 10}) async {
    try {
      final querySnapshot = await _firestoreService.getCollectionWhere(
        _emotionLogsCollection,
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
      throw Exception('Failed to get recent emotion logs: $e');
    }
  }

  @override
  Future<void> addSupportContact(String userId, SupportContact contact) async {
    try {
      final userProfile = await getUserProfile(userId);
      if (userProfile == null) {
        throw Exception('User profile not found');
      }

      final updatedContacts = [...userProfile.supportContacts, contact];
      
      await updateUserProfile(userId, {
        'supportContacts': updatedContacts.map((c) => c.toJson()).toList(),
      });
    } catch (e) {
      throw Exception('Failed to add support contact: $e');
    }
  }

  @override
  Future<void> removeSupportContact(String userId, String contactName) async {
    try {
      final userProfile = await getUserProfile(userId);
      if (userProfile == null) {
        throw Exception('User profile not found');
      }

      final updatedContacts = userProfile.supportContacts
          .where((contact) => contact.name != contactName)
          .toList();
      
      await updateUserProfile(userId, {
        'supportContacts': updatedContacts.map((c) => c.toJson()).toList(),
      });
    } catch (e) {
      throw Exception('Failed to remove support contact: $e');
    }
  }

  @override
  Future<void> updateSupportContact(String userId, SupportContact contact) async {
    try {
      final userProfile = await getUserProfile(userId);
      if (userProfile == null) {
        throw Exception('User profile not found');
      }

      final updatedContacts = userProfile.supportContacts.map((c) {
        return c.name == contact.name ? contact : c;
      }).toList();
      
      await updateUserProfile(userId, {
        'supportContacts': updatedContacts.map((c) => c.toJson()).toList(),
      });
    } catch (e) {
      throw Exception('Failed to update support contact: $e');
    }
  }

  @override
  Future<void> completeOnboarding(String userId) async {
    try {
      await updateUserProfile(userId, {
        'hasCompletedOnboarding': true,
      });
    } catch (e) {
      throw Exception('Failed to complete onboarding: $e');
    }
  }

  @override
  Future<void> updateCopingPreference(String userId, String preference) async {
    try {
      await updateUserProfile(userId, {
        'copingPreference': preference,
      });
    } catch (e) {
      throw Exception('Failed to update coping preference: $e');
    }
  }

  @override
  Future<EmotionalHistory?> getEmotionalHistory(String userId) async {
    try {
      final userProfile = await getUserProfile(userId);
      return userProfile?.emotionalHistory;
    } catch (e) {
      throw Exception('Failed to get emotional history: $e');
    }
  }

  @override
  Future<void> updateEmotionalHistory(String userId, EmotionalHistory history) async {
    try {
      await updateUserProfile(userId, {
        'emotionalHistory': history.toJson(),
      });
    } catch (e) {
      throw Exception('Failed to update emotional history: $e');
    }
  }

  /// Convert UserProfile to Firestore format
  Map<String, dynamic> _userProfileToFirestore(UserProfile profile) {
    final data = profile.toJson();
    
    // Convert DateTime fields to Firestore Timestamps
    if (profile.createdAt != null) {
      data['createdAt'] = Timestamp.fromDate(profile.createdAt!);
    }
    if (profile.updatedAt != null) {
      data['updatedAt'] = Timestamp.fromDate(profile.updatedAt!);
    }
    
    return data;
  }

  /// Convert Firestore data to UserProfile
  UserProfile _userProfileFromFirestore(Map<String, dynamic> data, String uid) {
    // Convert Timestamps back to DateTime
    if (data['createdAt'] is Timestamp) {
      data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
    }
    if (data['updatedAt'] is Timestamp) {
      data['updatedAt'] = (data['updatedAt'] as Timestamp).toDate().toIso8601String();
    }
    
    data['uid'] = uid;
    return UserProfile.fromJson(data);
  }

  /// Convert Firestore data to EmotionLog
  EmotionLog _emotionLogFromFirestore(Map<String, dynamic> data, String id) {
    // Convert Timestamp back to DateTime
    if (data['timestamp'] is Timestamp) {
      final timestamp = (data['timestamp'] as Timestamp).toDate();
      data['timestamp'] = timestamp.toIso8601String();
    }
    
    data['id'] = id;
    return EmotionLog.fromJson(data);
  }
}