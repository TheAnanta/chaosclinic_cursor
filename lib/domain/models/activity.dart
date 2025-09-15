import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity.freezed.dart';
part 'activity.g.dart';

@freezed
class Activity with _$Activity {
  const factory Activity({
    required String id,
    required String title,
    required String description,
    required ActivityType type,
    required String assetPath,
    @Default(5) int estimatedDurationMinutes,
    @Default([]) List<String> benefits,
    @Default([]) List<String> targetEmotions,
    @Default(0.0) double difficultyLevel, // 0.0 to 1.0
    @Default(false) bool isUnlocked,
    @Default(false) bool isCompleted,
    DateTime? lastCompletedAt,
    @Default(0) int completionCount,
    Map<String, dynamic>? gameData,
  }) = _Activity;

  factory Activity.fromJson(Map<String, Object?> json) =>
      _$ActivityFromJson(json);
}

enum ActivityType {
  game,
  meditation,
  grounding,
  breathing,
  journaling,
  education,
}

/// Extension methods for Activity
extension ActivityExtensions on Activity {
  /// Get activity type display name
  String get typeDisplayName {
    switch (type) {
      case ActivityType.game:
        return 'Mini-Game';
      case ActivityType.meditation:
        return 'Meditation';
      case ActivityType.grounding:
        return 'Grounding Exercise';
      case ActivityType.breathing:
        return 'Breathing Exercise';
      case ActivityType.journaling:
        return 'Journaling';
      case ActivityType.education:
        return 'Educational Content';
    }
  }

  /// Get difficulty level as readable string
  String get difficultyDisplayName {
    if (difficultyLevel <= 0.33) return 'Easy';
    if (difficultyLevel <= 0.66) return 'Medium';
    return 'Hard';
  }

  /// Check if activity is recommended for current mood
  bool isRecommendedFor(String currentMood) {
    return targetEmotions.contains(currentMood.toLowerCase()) ||
        targetEmotions.isEmpty;
  }

  /// Get estimated completion time as readable string
  String get estimatedTimeDisplay {
    if (estimatedDurationMinutes < 60) {
      return '$estimatedDurationMinutes min';
    } else {
      final hours = estimatedDurationMinutes ~/ 60;
      final minutes = estimatedDurationMinutes % 60;
      if (minutes == 0) {
        return '${hours}h';
      } else {
        return '${hours}h ${minutes}m';
      }
    }
  }
}