import '../models/user_profile.dart';
import '../models/emotion_log.dart';

/// Abstract repository for user operations
abstract class UserRepository {
  /// Get user profile by ID
  Future<UserProfile?> getUserProfile(String userId);
  
  /// Create or update user profile
  Future<void> saveUserProfile(UserProfile profile);
  
  /// Update user profile
  Future<void> updateUserProfile(String userId, Map<String, dynamic> updates);
  
  /// Delete user profile
  Future<void> deleteUserProfile(String userId);
  
  /// Get recent emotion logs for user
  Future<List<EmotionLog>> getRecentEmotionLogs(String userId, {int limit = 10});
  
  /// Add support contact to user profile
  Future<void> addSupportContact(String userId, SupportContact contact);
  
  /// Remove support contact from user profile
  Future<void> removeSupportContact(String userId, String contactName);
  
  /// Update support contact
  Future<void> updateSupportContact(String userId, SupportContact contact);
  
  /// Mark onboarding as completed
  Future<void> completeOnboarding(String userId);
  
  /// Update coping preference
  Future<void> updateCopingPreference(String userId, String preference);
  
  /// Get user's emotional history summary
  Future<EmotionalHistory?> getEmotionalHistory(String userId);
  
  /// Update emotional history
  Future<void> updateEmotionalHistory(String userId, EmotionalHistory history);
}