import '../models/activity.dart';

/// Abstract repository for activity operations
abstract class ActivityRepository {
  /// Get all available activities
  Future<List<Activity>> getAllActivities();
  
  /// Get activity by ID
  Future<Activity?> getActivity(String activityId);
  
  /// Get recommended activity based on criteria
  Future<Activity?> getRecommendedActivity({
    String? targetMood,
    double? difficultyLevel,
  });
  
  /// Get multiple recommended activities
  Future<List<Activity>> getRecommendedActivities({
    List<String>? targetMoods,
    double? difficultyLevel,
    int limit = 5,
  });
  
  /// Get recommended activities for specific user
  Future<List<Activity>> getRecommendedActivitiesForUser(
    String userId, {
    int limit = 5,
  });
  
  /// Get activities by type
  Future<List<Activity>> getActivitiesByType(
    ActivityType type, {
    int? limit,
  });
  
  /// Get activities by difficulty level
  Future<List<Activity>> getActivitiesByDifficulty(
    double difficultyLevel, {
    int limit = 5,
  });
  
  /// Update activity completion status
  Future<void> markActivityCompleted(String userId, String activityId);
  
  /// Get user's completed activities
  Future<List<Activity>> getCompletedActivities(String userId);
  
  /// Get user's activity history
  Future<List<Map<String, dynamic>>> getActivityHistory(String userId);
  
  /// Save activity progress
  Future<void> saveActivityProgress(
    String userId,
    String activityId,
    Map<String, dynamic> progressData,
  );
  
  /// Get activity progress for user
  Future<Map<String, dynamic>?> getActivityProgress(
    String userId,
    String activityId,
  );
}