import '../../data/repositories/user_repository.dart';
import '../models/user_profile.dart';

/// Use case for submitting onboarding data
class SubmitOnboardingUseCase {
  final UserRepository _userRepository;

  SubmitOnboardingUseCase(this._userRepository);

  /// Submit onboarding data for a user
  Future<bool> call({
    required String userId,
    required String copingPreference,
    required String trustedContactName,
    String? trustedContactPhone,
    String? trustedContactEmail,
    String? trustedContactRelationship,
  }) async {
    try {
      // Validate inputs
      final validationResult = _validateInputs(
        copingPreference: copingPreference,
        trustedContactName: trustedContactName,
        trustedContactPhone: trustedContactPhone,
        trustedContactEmail: trustedContactEmail,
      );

      if (!validationResult.isValid) {
        throw Exception(validationResult.errorMessage);
      }

      // Create support contact
      final supportContact = SupportContact(
        name: trustedContactName.trim(),
        relationship: trustedContactRelationship ?? 'Friend',
        phoneNumber: trustedContactPhone?.trim(),
        email: trustedContactEmail?.trim(),
        isPrimary: true,
      );

      // Update user profile with onboarding data
      final updates = {
        'copingPreference': copingPreference,
        'supportContacts': [supportContact.toJson()],
        'hasCompletedOnboarding': true,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await _userRepository.updateUserProfile(userId, updates);
      
      return true;
    } catch (e) {
      // Log error for debugging but don't expose internal details
      return false;
    }
  }

  /// Validate onboarding inputs
  OnboardingValidationResult _validateInputs({
    required String copingPreference,
    required String trustedContactName,
    String? trustedContactPhone,
    String? trustedContactEmail,
  }) {
    // Validate coping preference
    if (copingPreference.trim().isEmpty) {
      return OnboardingValidationResult(
        isValid: false,
        errorMessage: 'Please select a coping preference',
      );
    }

    // Validate trusted contact name
    if (trustedContactName.trim().isEmpty) {
      return OnboardingValidationResult(
        isValid: false,
        errorMessage: 'Please enter a trusted contact name',
      );
    }

    if (trustedContactName.trim().length < 2) {
      return OnboardingValidationResult(
        isValid: false,
        errorMessage: 'Trusted contact name must be at least 2 characters',
      );
    }

    // Validate contact information (at least one must be provided)
    final hasPhone = trustedContactPhone?.trim().isNotEmpty ?? false;
    final hasEmail = trustedContactEmail?.trim().isNotEmpty ?? false;

    if (!hasPhone && !hasEmail) {
      return OnboardingValidationResult(
        isValid: false,
        errorMessage: 'Please provide either a phone number or email for your trusted contact',
      );
    }

    // Validate email format if provided
    if (hasEmail && !_isValidEmail(trustedContactEmail!.trim())) {
      return OnboardingValidationResult(
        isValid: false,
        errorMessage: 'Please enter a valid email address',
      );
    }

    // Validate phone format if provided
    if (hasPhone && !_isValidPhone(trustedContactPhone!.trim())) {
      return OnboardingValidationResult(
        isValid: false,
        errorMessage: 'Please enter a valid phone number',
      );
    }

    return OnboardingValidationResult(isValid: true);
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Validate phone format (basic validation)
  bool _isValidPhone(String phone) {
    // Remove common formatting characters
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    
    // Check if it's all digits and reasonable length (7-15 digits)
    return RegExp(r'^\d{7,15}$').hasMatch(cleanPhone);
  }
}

/// Result of onboarding validation
class OnboardingValidationResult {
  final bool isValid;
  final String? errorMessage;

  OnboardingValidationResult({
    required this.isValid,
    this.errorMessage,
  });
}