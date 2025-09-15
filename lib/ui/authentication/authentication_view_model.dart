import 'package:flutter/foundation.dart';
import '../../data/services/authentication_service.dart';
import '../../data/repositories/user_repository.dart';
import '../../domain/models/user_profile.dart';

/// Authentication state enumeration
enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// View model for authentication flow
class AuthenticationViewModel extends ChangeNotifier {
  final AuthenticationService _authService;
  final UserRepository _userRepository;

  AuthenticationViewModel(this._authService, this._userRepository) {
    _listenToAuthChanges();
  }

  AuthState _state = AuthState.initial;
  String? _errorMessage;
  UserProfile? _currentUser;
  bool _isLoading = false;

  // Getters
  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  UserProfile? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _state == AuthState.authenticated;

  /// Listen to authentication state changes
  void _listenToAuthChanges() {
    _authService.authStateChanges.listen((user) async {
      if (user != null) {
        await _loadUserProfile(user.uid);
        _setState(AuthState.authenticated);
      } else {
        _currentUser = null;
        _setState(AuthState.unauthenticated);
      }
    });
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      _setLoading(true);
      _clearError();

      final userCredential = await _authService.signInWithGoogle();
      
      if (userCredential?.user != null) {
        final user = userCredential!.user!;
        
        // Check if user profile exists, create if not
        final existingProfile = await _userRepository.getUserProfile(user.uid);
        
        if (existingProfile == null) {
          // Create new user profile
          final newProfile = UserProfile(
            uid: user.uid,
            displayName: user.displayName ?? 'Unknown User',
            email: user.email ?? '',
            createdAt: DateTime.now(),
          );
          
          await _userRepository.saveUserProfile(newProfile);
          _currentUser = newProfile;
        } else {
          _currentUser = existingProfile;
        }
        
        _setState(AuthState.authenticated);
      } else {
        _setError('Failed to sign in with Google');
      }
    } catch (e) {
      _setError('Sign in failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Sign in with email and password
  Future<void> signInWithEmail(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();

      if (!_isValidEmail(email)) {
        throw Exception('Please enter a valid email address');
      }

      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      final userCredential = await _authService.signInWithEmailAndPassword(
        email,
        password,
      );

      if (userCredential?.user != null) {
        await _loadUserProfile(userCredential!.user!.uid);
        _setState(AuthState.authenticated);
      } else {
        _setError('Failed to sign in');
      }
    } catch (e) {
      _setError('Sign in failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Create account with email and password
  Future<void> createAccount(String email, String password, String displayName) async {
    try {
      _setLoading(true);
      _clearError();

      if (!_isValidEmail(email)) {
        throw Exception('Please enter a valid email address');
      }

      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      if (displayName.trim().length < 2) {
        throw Exception('Please enter a valid name');
      }

      final userCredential = await _authService.createUserWithEmailAndPassword(
        email,
        password,
      );

      if (userCredential?.user != null) {
        final user = userCredential!.user!;
        
        // Update display name
        await _authService.updateDisplayName(displayName.trim());
        
        // Create user profile
        final newProfile = UserProfile(
          uid: user.uid,
          displayName: displayName.trim(),
          email: email,
          createdAt: DateTime.now(),
        );
        
        await _userRepository.saveUserProfile(newProfile);
        _currentUser = newProfile;
        _setState(AuthState.authenticated);
      } else {
        _setError('Failed to create account');
      }
    } catch (e) {
      _setError('Account creation failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _authService.signOut();
      _currentUser = null;
      _setState(AuthState.unauthenticated);
    } catch (e) {
      _setError('Sign out failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      _setLoading(true);
      _clearError();

      if (!_isValidEmail(email)) {
        throw Exception('Please enter a valid email address');
      }

      await _authService.sendPasswordResetEmail(email);
      
      // Show success message (handled by UI)
    } catch (e) {
      _setError('Failed to send reset email: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Load user profile from repository
  Future<void> _loadUserProfile(String userId) async {
    try {
      final profile = await _userRepository.getUserProfile(userId);
      _currentUser = profile;
    } catch (e) {
      debugPrint('Failed to load user profile: $e');
    }
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set authentication state
  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Set error message
  void _setError(String message) {
    _errorMessage = message;
    _state = AuthState.error;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) {
      _state = AuthState.initial;
    }
    notifyListeners();
  }

  /// Clear all state
  void clear() {
    _state = AuthState.initial;
    _errorMessage = null;
    _currentUser = null;
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}