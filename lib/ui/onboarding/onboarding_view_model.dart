import 'package:flutter/foundation.dart';
import '../../domain/use_cases/submit_onboarding_use_case.dart';

/// Onboarding state enumeration
enum OnboardingState {
  initial,
  loading,
  completed,
  error,
}

/// Available coping preferences
enum CopingPreference {
  meditation('Meditation & Mindfulness', '🧘‍♀️'),
  exercise('Physical Exercise', '🏃‍♀️'),
  journaling('Journaling & Writing', '📝'),
  music('Music & Arts', '🎵'),
  socialSupport('Talking to Friends', '👥'),
  nature('Time in Nature', '🌿'),
  breathing('Breathing Exercises', '💨'),
  creative('Creative Activities', '🎨');

  const CopingPreference(this.displayName, this.emoji);

  final String displayName;
  final String emoji;
}

/// Available relationship types for trusted contacts
enum ContactRelationship {
  family('Family Member'),
  friend('Friend'),
  partner('Partner/Spouse'),
  therapist('Therapist/Counselor'),
  colleague('Colleague'),
  other('Other');

  const ContactRelationship(this.displayName);

  final String displayName;
}

/// View model for onboarding flow
class OnboardingViewModel extends ChangeNotifier {
  final SubmitOnboardingUseCase _submitOnboardingUseCase;
  final String userId;

  OnboardingViewModel(this._submitOnboardingUseCase, this.userId);

  // Current page in onboarding flow
  int _currentPage = 0;
  
  // State
  OnboardingState _state = OnboardingState.initial;
  String? _errorMessage;
  bool _isLoading = false;

  // Onboarding data
  CopingPreference? _selectedCopingPreference;
  String _trustedContactName = '';
  String _trustedContactPhone = '';
  String _trustedContactEmail = '';
  ContactRelationship _contactRelationship = ContactRelationship.friend;

  // Getters
  int get currentPage => _currentPage;
  OnboardingState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  CopingPreference? get selectedCopingPreference => _selectedCopingPreference;
  String get trustedContactName => _trustedContactName;
  String get trustedContactPhone => _trustedContactPhone;
  String get trustedContactEmail => _trustedContactEmail;
  ContactRelationship get contactRelationship => _contactRelationship;

  // Navigation helpers
  bool get isFirstPage => _currentPage == 0;
  bool get isLastPage => _currentPage == 2; // Assuming 3 pages (0, 1, 2)
  bool get canProceedFromCurrentPage => _canProceedFromPage(_currentPage);

  /// Set current page
  void setCurrentPage(int page) {
    if (page >= 0 && page <= 2) {
      _currentPage = page;
      _clearError();
      notifyListeners();
    }
  }

  /// Go to next page
  void nextPage() {
    if (!isLastPage && canProceedFromCurrentPage) {
      _currentPage++;
      _clearError();
      notifyListeners();
    }
  }

  /// Go to previous page
  void previousPage() {
    if (!isFirstPage) {
      _currentPage--;
      _clearError();
      notifyListeners();
    }
  }

  /// Set selected coping preference
  void setCopingPreference(CopingPreference preference) {
    _selectedCopingPreference = preference;
    _clearError();
    notifyListeners();
  }

  /// Set trusted contact name
  void setTrustedContactName(String name) {
    _trustedContactName = name.trim();
    _clearError();
    notifyListeners();
  }

  /// Set trusted contact phone
  void setTrustedContactPhone(String phone) {
    _trustedContactPhone = phone.trim();
    _clearError();
    notifyListeners();
  }

  /// Set trusted contact email
  void setTrustedContactEmail(String email) {
    _trustedContactEmail = email.trim();
    _clearError();
    notifyListeners();
  }

  /// Set contact relationship
  void setContactRelationship(ContactRelationship relationship) {
    _contactRelationship = relationship;
    notifyListeners();
  }

  /// Submit onboarding data
  Future<void> submitOnboarding() async {
    try {
      _setLoading(true);
      _clearError();

      // Validate all required data
      if (!_isOnboardingDataValid()) {
        _setError('Please complete all required fields');
        return;
      }

      final success = await _submitOnboardingUseCase.call(
        userId: userId,
        copingPreference: _selectedCopingPreference!.displayName,
        trustedContactName: _trustedContactName,
        trustedContactPhone: _trustedContactPhone.isNotEmpty ? _trustedContactPhone : null,
        trustedContactEmail: _trustedContactEmail.isNotEmpty ? _trustedContactEmail : null,
        trustedContactRelationship: _contactRelationship.displayName,
      );

      if (success) {
        _setState(OnboardingState.completed);
      } else {
        _setError('Failed to save onboarding data. Please try again.');
      }
    } catch (e) {
      _setError('An error occurred: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Check if user can proceed from current page
  bool _canProceedFromPage(int page) {
    switch (page) {
      case 0: // Welcome page
        return true;
      case 1: // Coping preference page
        return _selectedCopingPreference != null;
      case 2: // Trusted contact page
        return _isTrustedContactDataValid();
      default:
        return false;
    }
  }

  /// Validate trusted contact data
  bool _isTrustedContactDataValid() {
    if (_trustedContactName.trim().length < 2) {
      return false;
    }

    // At least one contact method must be provided
    final hasPhone = _trustedContactPhone.trim().isNotEmpty;
    final hasEmail = _trustedContactEmail.trim().isNotEmpty;
    
    return hasPhone || hasEmail;
  }

  /// Validate all onboarding data
  bool _isOnboardingDataValid() {
    return _selectedCopingPreference != null && _isTrustedContactDataValid();
  }

  /// Get validation message for current page
  String? getValidationMessageForCurrentPage() {
    switch (_currentPage) {
      case 1:
        if (_selectedCopingPreference == null) {
          return 'Please select a coping preference to continue';
        }
        break;
      case 2:
        if (_trustedContactName.trim().length < 2) {
          return 'Please enter a valid name for your trusted contact';
        }
        if (!_isTrustedContactDataValid()) {
          return 'Please provide either a phone number or email address';
        }
        break;
    }
    return null;
  }

  /// Reset onboarding data
  void reset() {
    _currentPage = 0;
    _state = OnboardingState.initial;
    _errorMessage = null;
    _isLoading = false;
    _selectedCopingPreference = null;
    _trustedContactName = '';
    _trustedContactPhone = '';
    _trustedContactEmail = '';
    _contactRelationship = ContactRelationship.friend;
    notifyListeners();
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set state
  void _setState(OnboardingState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Set error message
  void _setError(String message) {
    _errorMessage = message;
    _state = OnboardingState.error;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _errorMessage = null;
    if (_state == OnboardingState.error) {
      _state = OnboardingState.initial;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}