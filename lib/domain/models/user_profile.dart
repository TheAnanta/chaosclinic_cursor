import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String uid,
    required String displayName,
    required String email,
    @Default([]) List<SupportContact> supportContacts,
    EmotionalHistory? emotionalHistory,
    String? copingPreference,
    @Default(false) bool hasCompletedOnboarding,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, Object?> json) =>
      _$UserProfileFromJson(json);
}

@freezed
class SupportContact with _$SupportContact {
  const factory SupportContact({
    required String name,
    required String relationship,
    String? phoneNumber,
    String? email,
    @Default(false) bool isPrimary,
  }) = _SupportContact;

  factory SupportContact.fromJson(Map<String, Object?> json) =>
      _$SupportContactFromJson(json);
}

@freezed
class EmotionalHistory with _$EmotionalHistory {
  const factory EmotionalHistory({
    @Default([]) List<String> recentEmotions,
    @Default([]) List<String> patterns,
    DateTime? lastLoggedAt,
    @Default(0) int totalLogs,
  }) = _EmotionalHistory;

  factory EmotionalHistory.fromJson(Map<String, Object?> json) =>
      _$EmotionalHistoryFromJson(json);
}