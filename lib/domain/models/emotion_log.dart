import 'package:freezed_annotation/freezed_annotation.dart';

part 'emotion_log.freezed.dart';
part 'emotion_log.g.dart';

@freezed
class EmotionLog with _$EmotionLog {
  const factory EmotionLog({
    required String id,
    required DateTime timestamp,
    required String mood,
    required int intensity,
    String? note,
    String? userId,
    @Default([]) List<String> tags,
    EmotionLogType? type,
    Map<String, dynamic>? metadata,
  }) = _EmotionLog;

  factory EmotionLog.fromJson(Map<String, Object?> json) =>
      _$EmotionLogFromJson(json);
}

enum EmotionLogType { manual, automated, imported }

/// Extension methods for EmotionLog
extension EmotionLogExtensions on EmotionLog {
  /// Convert to health platform format
  Map<String, dynamic> toHealthPlatformData() {
    return {
      'mood': mood,
      'intensity': intensity,
      'timestamp': timestamp.toIso8601String(),
      'note': note,
      'tags': tags,
    };
  }

  /// Check if this is a recent log (within last 24 hours)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    return difference.inHours <= 24;
  }

  /// Get emotion intensity label
  String get intensityLabel {
    switch (intensity) {
      case 1:
        return 'Very Low';
      case 2:
        return 'Low';
      case 3:
        return 'Moderate';
      case 4:
        return 'High';
      case 5:
        return 'Very High';
      default:
        return 'Unknown';
    }
  }
}
