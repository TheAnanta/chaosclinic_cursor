import 'package:firebase_auth/firebase_auth.dart';

/// Abstract authentication service
abstract class AuthenticationService {
  /// Get current user
  User? get currentUser;
  
  /// Stream of authentication state changes
  Stream<User?> get authStateChanges;
  
  /// Sign in with Google
  Future<UserCredential?> signInWithGoogle();
  
  /// Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  );
  
  /// Create user with email and password
  Future<UserCredential?> createUserWithEmailAndPassword(
    String email,
    String password,
  );
  
  /// Sign out
  Future<void> signOut();
  
  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email);
  
  /// Delete current user account
  Future<void> deleteUser();
  
  /// Update user display name
  Future<void> updateDisplayName(String displayName);
  
  /// Update user email
  Future<void> updateEmail(String email);
  
  /// Check if user is authenticated
  bool get isAuthenticated;
  
  /// Get user ID
  String? get userId;
}

/// Firebase implementation of authentication service
class FirebaseAuthenticationService implements AuthenticationService {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthenticationService(this._firebaseAuth);

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  bool get isAuthenticated => currentUser != null;

  @override
  String? get userId => currentUser?.uid;

  @override
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // This would require google_sign_in package configuration
      // For now, returning null as placeholder
      return null;
    } catch (e) {
      throw AuthenticationException('Failed to sign in with Google: $e');
    }
  }

  @override
  Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw AuthenticationException('Failed to sign in: $e');
    }
  }

  @override
  Future<UserCredential?> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw AuthenticationException('Failed to create user: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw AuthenticationException('Failed to sign out: $e');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw AuthenticationException('Failed to send password reset email: $e');
    }
  }

  @override
  Future<void> deleteUser() async {
    try {
      await currentUser?.delete();
    } catch (e) {
      throw AuthenticationException('Failed to delete user: $e');
    }
  }

  @override
  Future<void> updateDisplayName(String displayName) async {
    try {
      await currentUser?.updateDisplayName(displayName);
    } catch (e) {
      throw AuthenticationException('Failed to update display name: $e');
    }
  }

  @override
  Future<void> updateEmail(String email) async {
    try {
      await currentUser?.updateEmail(email);
    } catch (e) {
      throw AuthenticationException('Failed to update email: $e');
    }
  }
}

/// Authentication exception
class AuthenticationException implements Exception {
  final String message;
  
  AuthenticationException(this.message);
  
  @override
  String toString() => 'AuthenticationException: $message';
}