import 'package:freezed_annotation/freezed_annotation.dart';

part 'challenge.freezed.dart';
part 'challenge.g.dart';

@freezed
class Challenge with _$Challenge {
  const factory Challenge({
    required String id,
    required String title,
    required String subtitle,
    required DateTime date,
    required String iconAssetPath,
    @Default(0.0) double progress,
    @Default(ChallengeType.daily) ChallengeType type,
    @Default(ChallengeDifficulty.easy) ChallengeDifficulty difficulty,
    @Default([]) List<String> requirements,
    @Default([]) List<String> rewards,
    @Default(false) bool isCompleted,
    @Default(false) bool isActive,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? completedAt,
    @Default(0) int participantCount,
    String? description,
    Map<String, dynamic>? metadata,
  }) = _Challenge;

  factory Challenge.fromJson(Map<String, Object?> json) =>
      _$ChallengeFromJson(json);
}

enum ChallengeType { daily, weekly, monthly, special }

enum ChallengeDifficulty { easy, medium, hard, expert }

/// Extension methods for Challenge
extension ChallengeExtensions on Challenge {
  /// Get progress as percentage string
  String get progressPercentage {
    return '${(progress * 100).round()}%';
  }

  /// Get challenge type display name
  String get typeDisplayName {
    switch (type) {
      case ChallengeType.daily:
        return 'Daily Challenge';
      case ChallengeType.weekly:
        return 'Weekly Challenge';
      case ChallengeType.monthly:
        return 'Monthly Challenge';
      case ChallengeType.special:
        return 'Special Challenge';
    }
  }

  /// Get difficulty display name with emoji
  String get difficultyDisplayName {
    switch (difficulty) {
      case ChallengeDifficulty.easy:
        return '⭐ Easy';
      case ChallengeDifficulty.medium:
        return '⭐⭐ Medium';
      case ChallengeDifficulty.hard:
        return '⭐⭐⭐ Hard';
      case ChallengeDifficulty.expert:
        return '⭐⭐⭐⭐ Expert';
    }
  }

  /// Check if challenge is currently active
  bool get isCurrentlyActive {
    if (!isActive) return false;

    final now = DateTime.now();
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;

    return true;
  }

  /// Get time remaining for challenge
  String get timeRemainingDisplay {
    if (endDate == null) return 'No time limit';

    final now = DateTime.now();
    if (now.isAfter(endDate!)) return 'Expired';

    final difference = endDate!.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays}d remaining';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h remaining';
    } else {
      return '${difference.inMinutes}m remaining';
    }
  }

  /// Get formatted participant count
  String get participantCountDisplay {
    if (participantCount >= 1000) {
      return '${(participantCount / 1000).toStringAsFixed(1)}k participants';
    } else {
      return '$participantCount participants';
    }
  }

  /// Check if challenge is near deadline (within 24 hours)
  bool get isNearDeadline {
    if (endDate == null) return false;

    final now = DateTime.now();
    final difference = endDate!.difference(now);

    return difference.inHours <= 24 && difference.inHours > 0;
  }
}
