import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_score.freezed.dart';
part 'user_score.g.dart';

@freezed
class UserScore with _$UserScore {
  const factory UserScore({
    required String userId,
    @Default(0) int totalScore,
    @Default(0) int gameScore,
    @Default(0) int meditationScore,
    @Default(0) int journalScore,
    @Default(0) int gratitudeScore,
    @Default(0) int emotionLogScore,
    @Default(0) int activitiesCompleted,
    @Default(0) int streakDays,
    DateTime? lastActivityAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _UserScore;

  factory UserScore.fromJson(Map<String, Object?> json) =>
      _$UserScoreFromJson(json);
}

@freezed
class ActivityScore with _$ActivityScore {
  const factory ActivityScore({
    required String id,
    required String userId,
    required String activityType,
    required String activityId,
    required int score,
    required DateTime completedAt,
    Map<String, dynamic>? metadata,
  }) = _ActivityScore;

  factory ActivityScore.fromJson(Map<String, Object?> json) =>
      _$ActivityScoreFromJson(json);
}

enum ActivityType {
  @JsonValue('game')
  game,
  @JsonValue('meditation')
  meditation,
  @JsonValue('journal')
  journal,
  @JsonValue('gratitude')
  gratitude,
  @JsonValue('emotion_log')
  emotionLog,
  @JsonValue('breathing')
  breathing,
}

/// Extension methods for scoring
extension UserScoreExtensions on UserScore {
  /// Get formatted total score
  String get formattedTotalScore {
    if (totalScore >= 1000000) {
      return '${(totalScore / 1000000).toStringAsFixed(1)}M';
    } else if (totalScore >= 1000) {
      return '${(totalScore / 1000).toStringAsFixed(1)}K';
    } else {
      return totalScore.toString();
    }
  }

  /// Get user level based on total score
  int get level {
    if (totalScore < 100) return 1;
    if (totalScore < 500) return 2;
    if (totalScore < 1000) return 3;
    if (totalScore < 2500) return 4;
    if (totalScore < 5000) return 5;
    if (totalScore < 10000) return 6;
    if (totalScore < 25000) return 7;
    if (totalScore < 50000) return 8;
    if (totalScore < 100000) return 9;
    return 10;
  }

  /// Get level title
  String get levelTitle {
    switch (level) {
      case 1:
        return 'Beginner';
      case 2:
        return 'Explorer';
      case 3:
        return 'Practitioner';
      case 4:
        return 'Focused';
      case 5:
        return 'Dedicated';
      case 6:
        return 'Committed';
      case 7:
        return 'Expert';
      case 8:
        return 'Master';
      case 9:
        return 'Sage';
      case 10:
        return 'Enlightened';
      default:
        return 'Warrior';
    }
  }

  /// Get progress to next level
  double get progressToNextLevel {
    final currentLevelThreshold = _getLevelThreshold(level);
    final nextLevelThreshold = _getLevelThreshold(level + 1);
    
    if (nextLevelThreshold == currentLevelThreshold) return 1.0;
    
    return (totalScore - currentLevelThreshold) / (nextLevelThreshold - currentLevelThreshold);
  }

  int _getLevelThreshold(int level) {
    switch (level) {
      case 1:
        return 0;
      case 2:
        return 100;
      case 3:
        return 500;
      case 4:
        return 1000;
      case 5:
        return 2500;
      case 6:
        return 5000;
      case 7:
        return 10000;
      case 8:
        return 25000;
      case 9:
        return 50000;
      case 10:
        return 100000;
      default:
        return 100000;
    }
  }
}

/// Scoring system constants
class ScoringSystem {
  static const int gameCompletionScore = 50;
  static const int meditationCompletionScore = 75;
  static const int journalEntryScore = 30;
  static const int gratitudePracticeScore = 25;
  static const int emotionLogScore = 10;
  static const int breathingExerciseScore = 20;
  static const int dailyStreakBonus = 10;
  static const int weeklyStreakBonus = 50;
  
  /// Calculate score for specific activity
  static int calculateActivityScore(ActivityType activityType, {Map<String, dynamic>? metadata}) {
    switch (activityType) {
      case ActivityType.game:
        // Base score + bonus for performance
        int baseScore = gameCompletionScore;
        if (metadata != null) {
          final performance = metadata['performance'] as double? ?? 0.0;
          baseScore += (performance * 25).round(); // Up to 25 bonus points
        }
        return baseScore;
        
      case ActivityType.meditation:
        // Score based on duration
        int baseScore = meditationCompletionScore;
        if (metadata != null) {
          final durationMinutes = metadata['duration_minutes'] as int? ?? 1;
          baseScore += (durationMinutes * 2).clamp(0, 50); // Up to 50 bonus for long sessions
        }
        return baseScore;
        
      case ActivityType.journal:
        // Score based on content length and depth
        int baseScore = journalEntryScore;
        if (metadata != null) {
          final wordCount = metadata['word_count'] as int? ?? 0;
          final hasGratitude = metadata['has_gratitude'] as bool? ?? false;
          baseScore += (wordCount / 10).round().clamp(0, 20); // Up to 20 for longer entries
          if (hasGratitude) baseScore += 10; // Bonus for gratitude
        }
        return baseScore;
        
      case ActivityType.gratitude:
        return gratitudePracticeScore;
        
      case ActivityType.emotionLog:
        return emotionLogScore;
        
      case ActivityType.breathing:
        return breathingExerciseScore;
    }
  }
}