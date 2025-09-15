import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chaosclinic/ui/authentication/authentication_view_model.dart';
import 'package:chaosclinic/data/services/authentication_service.dart';
import 'package:chaosclinic/data/repositories/user_repository.dart';
import 'package:chaosclinic/domain/models/user_profile.dart';

// Generate mocks
@GenerateMocks([
  AuthenticationService,
  UserRepository,
  User,
  UserCredential,
])
import 'authentication_view_model_test.mocks.dart';

void main() {
  group('AuthenticationViewModel', () {
    late AuthenticationViewModel viewModel;
    late MockAuthenticationService mockAuthService;
    late MockUserRepository mockUserRepository;
    late MockUser mockUser;
    late MockUserCredential mockUserCredential;

    setUp(() {
      mockAuthService = MockAuthenticationService();
      mockUserRepository = MockUserRepository();
      mockUser = MockUser();
      mockUserCredential = MockUserCredential();
      
      // Setup mock streams
      when(mockAuthService.authStateChanges).thenAnswer((_) => Stream.value(null));
      
      viewModel = AuthenticationViewModel(mockAuthService, mockUserRepository);
    });

    tearDown(() {
      viewModel.dispose();
    });

    group('Initial State', () {
      test('should start with initial state', () {
        expect(viewModel.state, AuthState.initial);
        expect(viewModel.isLoading, false);
        expect(viewModel.errorMessage, null);
        expect(viewModel.currentUser, null);
        expect(viewModel.isAuthenticated, false);
      });
    });

    group('Sign In with Google', () {
      test('should successfully sign in new user with Google', () async {
        // Arrange
        when(mockUser.uid).thenReturn('test-uid');
        when(mockUser.displayName).thenReturn('Test User');
        when(mockUser.email).thenReturn('test@example.com');
        when(mockUserCredential.user).thenReturn(mockUser);
        
        when(mockAuthService.signInWithGoogle())
            .thenAnswer((_) async => mockUserCredential);
        when(mockUserRepository.getUserProfile('test-uid'))
            .thenAnswer((_) async => null);
        when(mockUserRepository.saveUserProfile(any))
            .thenAnswer((_) async {});

        // Act
        await viewModel.signInWithGoogle();

        // Assert
        expect(viewModel.state, AuthState.authenticated);
        expect(viewModel.isLoading, false);
        expect(viewModel.errorMessage, null);
        expect(viewModel.currentUser?.uid, 'test-uid');
        expect(viewModel.currentUser?.displayName, 'Test User');
        expect(viewModel.currentUser?.email, 'test@example.com');
        
        verify(mockAuthService.signInWithGoogle()).called(1);
        verify(mockUserRepository.getUserProfile('test-uid')).called(1);
        verify(mockUserRepository.saveUserProfile(any)).called(1);
      });

      test('should successfully sign in existing user with Google', () async {
        // Arrange
        final existingProfile = UserProfile(
          uid: 'test-uid',
          displayName: 'Existing User',
          email: 'existing@example.com',
        );
        
        when(mockUser.uid).thenReturn('test-uid');
        when(mockUserCredential.user).thenReturn(mockUser);
        
        when(mockAuthService.signInWithGoogle())
            .thenAnswer((_) async => mockUserCredential);
        when(mockUserRepository.getUserProfile('test-uid'))
            .thenAnswer((_) async => existingProfile);

        // Act
        await viewModel.signInWithGoogle();

        // Assert
        expect(viewModel.state, AuthState.authenticated);
        expect(viewModel.currentUser, existingProfile);
        
        verify(mockAuthService.signInWithGoogle()).called(1);
        verify(mockUserRepository.getUserProfile('test-uid')).called(1);
        verifyNever(mockUserRepository.saveUserProfile(any));
      });

      test('should handle Google sign in failure', () async {
        // Arrange
        when(mockAuthService.signInWithGoogle())
            .thenThrow(Exception('Google sign in failed'));

        // Act
        await viewModel.signInWithGoogle();

        // Assert
        expect(viewModel.state, AuthState.error);
        expect(viewModel.errorMessage, contains('Sign in failed'));
        expect(viewModel.isLoading, false);
        expect(viewModel.currentUser, null);
      });

      test('should handle null user credential from Google', () async {
        // Arrange
        when(mockAuthService.signInWithGoogle())
            .thenAnswer((_) async => null);

        // Act
        await viewModel.signInWithGoogle();

        // Assert
        expect(viewModel.state, AuthState.error);
        expect(viewModel.errorMessage, 'Failed to sign in with Google');
        expect(viewModel.isLoading, false);
      });
    });

    group('Sign In with Email', () {
      test('should successfully sign in with valid email and password', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        final userProfile = UserProfile(
          uid: 'test-uid',
          displayName: 'Test User',
          email: email,
        );
        
        when(mockUser.uid).thenReturn('test-uid');
        when(mockUserCredential.user).thenReturn(mockUser);
        
        when(mockAuthService.signInWithEmailAndPassword(email, password))
            .thenAnswer((_) async => mockUserCredential);
        when(mockUserRepository.getUserProfile('test-uid'))
            .thenAnswer((_) async => userProfile);

        // Act
        await viewModel.signInWithEmail(email, password);

        // Assert
        expect(viewModel.state, AuthState.authenticated);
        expect(viewModel.currentUser, userProfile);
        expect(viewModel.isLoading, false);
        expect(viewModel.errorMessage, null);
        
        verify(mockAuthService.signInWithEmailAndPassword(email, password)).called(1);
        verify(mockUserRepository.getUserProfile('test-uid')).called(1);
      });

      test('should reject invalid email format', () async {
        // Arrange
        const invalidEmail = 'invalid-email';
        const password = 'password123';

        // Act
        await viewModel.signInWithEmail(invalidEmail, password);

        // Assert
        expect(viewModel.state, AuthState.error);
        expect(viewModel.errorMessage, contains('valid email address'));
        expect(viewModel.isLoading, false);
        
        verifyNever(mockAuthService.signInWithEmailAndPassword(any, any));
      });

      test('should reject password shorter than 6 characters', () async {
        // Arrange
        const email = 'test@example.com';
        const shortPassword = '123';

        // Act
        await viewModel.signInWithEmail(email, shortPassword);

        // Assert
        expect(viewModel.state, AuthState.error);
        expect(viewModel.errorMessage, contains('at least 6 characters'));
        expect(viewModel.isLoading, false);
        
        verifyNever(mockAuthService.signInWithEmailAndPassword(any, any));
      });

      test('should handle authentication failure', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'wrongpassword';
        
        when(mockAuthService.signInWithEmailAndPassword(email, password))
            .thenThrow(Exception('Invalid credentials'));

        // Act
        await viewModel.signInWithEmail(email, password);

        // Assert
        expect(viewModel.state, AuthState.error);
        expect(viewModel.errorMessage, contains('Sign in failed'));
        expect(viewModel.isLoading, false);
      });
    });

    group('Create Account', () {
      test('should successfully create account with valid data', () async {
        // Arrange
        const email = 'newuser@example.com';
        const password = 'password123';
        const displayName = 'New User';
        
        when(mockUser.uid).thenReturn('new-uid');
        when(mockUserCredential.user).thenReturn(mockUser);
        
        when(mockAuthService.createUserWithEmailAndPassword(email, password))
            .thenAnswer((_) async => mockUserCredential);
        when(mockAuthService.updateDisplayName(displayName))
            .thenAnswer((_) async {});
        when(mockUserRepository.saveUserProfile(any))
            .thenAnswer((_) async {});

        // Act
        await viewModel.createAccount(email, password, displayName);

        // Assert
        expect(viewModel.state, AuthState.authenticated);
        expect(viewModel.currentUser?.uid, 'new-uid');
        expect(viewModel.currentUser?.displayName, displayName);
        expect(viewModel.currentUser?.email, email);
        expect(viewModel.isLoading, false);
        
        verify(mockAuthService.createUserWithEmailAndPassword(email, password)).called(1);
        verify(mockAuthService.updateDisplayName(displayName)).called(1);
        verify(mockUserRepository.saveUserProfile(any)).called(1);
      });

      test('should reject invalid email for account creation', () async {
        // Arrange
        const invalidEmail = 'not-an-email';
        const password = 'password123';
        const displayName = 'Test User';

        // Act
        await viewModel.createAccount(invalidEmail, password, displayName);

        // Assert
        expect(viewModel.state, AuthState.error);
        expect(viewModel.errorMessage, contains('valid email address'));
        
        verifyNever(mockAuthService.createUserWithEmailAndPassword(any, any));
      });

      test('should reject short password for account creation', () async {
        // Arrange
        const email = 'test@example.com';
        const shortPassword = '123';
        const displayName = 'Test User';

        // Act
        await viewModel.createAccount(email, shortPassword, displayName);

        // Assert
        expect(viewModel.state, AuthState.error);
        expect(viewModel.errorMessage, contains('at least 6 characters'));
        
        verifyNever(mockAuthService.createUserWithEmailAndPassword(any, any));
      });

      test('should reject short display name', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        const shortName = 'A';

        // Act
        await viewModel.createAccount(email, password, shortName);

        // Assert
        expect(viewModel.state, AuthState.error);
        expect(viewModel.errorMessage, contains('valid name'));
        
        verifyNever(mockAuthService.createUserWithEmailAndPassword(any, any));
      });

      test('should handle account creation failure', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        const displayName = 'Test User';
        
        when(mockAuthService.createUserWithEmailAndPassword(email, password))
            .thenThrow(Exception('Email already in use'));

        // Act
        await viewModel.createAccount(email, password, displayName);

        // Assert
        expect(viewModel.state, AuthState.error);
        expect(viewModel.errorMessage, contains('Account creation failed'));
        expect(viewModel.isLoading, false);
      });
    });

    group('Sign Out', () {
      test('should successfully sign out', () async {
        // Arrange
        when(mockAuthService.signOut()).thenAnswer((_) async {});

        // Act
        await viewModel.signOut();

        // Assert
        expect(viewModel.state, AuthState.unauthenticated);
        expect(viewModel.currentUser, null);
        expect(viewModel.isLoading, false);
        
        verify(mockAuthService.signOut()).called(1);
      });

      test('should handle sign out failure', () async {
        // Arrange
        when(mockAuthService.signOut())
            .thenThrow(Exception('Sign out failed'));

        // Act
        await viewModel.signOut();

        // Assert
        expect(viewModel.state, AuthState.error);
        expect(viewModel.errorMessage, contains('Sign out failed'));
        expect(viewModel.isLoading, false);
      });
    });

    group('Password Reset', () {
      test('should successfully send password reset email', () async {
        // Arrange
        const email = 'test@example.com';
        when(mockAuthService.sendPasswordResetEmail(email))
            .thenAnswer((_) async {});

        // Act
        await viewModel.sendPasswordResetEmail(email);

        // Assert
        expect(viewModel.isLoading, false);
        expect(viewModel.errorMessage, null);
        
        verify(mockAuthService.sendPasswordResetEmail(email)).called(1);
      });

      test('should reject invalid email for password reset', () async {
        // Arrange
        const invalidEmail = 'not-an-email';

        // Act
        await viewModel.sendPasswordResetEmail(invalidEmail);

        // Assert
        expect(viewModel.state, AuthState.error);
        expect(viewModel.errorMessage, contains('valid email address'));
        
        verifyNever(mockAuthService.sendPasswordResetEmail(any));
      });

      test('should handle password reset failure', () async {
        // Arrange
        const email = 'test@example.com';
        when(mockAuthService.sendPasswordResetEmail(email))
            .thenThrow(Exception('User not found'));

        // Act
        await viewModel.sendPasswordResetEmail(email);

        // Assert
        expect(viewModel.state, AuthState.error);
        expect(viewModel.errorMessage, contains('Failed to send reset email'));
        expect(viewModel.isLoading, false);
      });
    });

    group('State Management', () {
      test('should clear all state correctly', () {
        // Arrange - set some state first
        viewModel.signInWithEmail('invalid', '123'); // Will set error state
        
        // Act
        viewModel.clear();

        // Assert
        expect(viewModel.state, AuthState.initial);
        expect(viewModel.errorMessage, null);
        expect(viewModel.currentUser, null);
        expect(viewModel.isLoading, false);
      });

      test('should clear error when starting new operation', () async {
        // Arrange - set error state first
        await viewModel.signInWithEmail('invalid', '123');
        expect(viewModel.state, AuthState.error);
        
        // Setup for successful operation
        when(mockUser.uid).thenReturn('test-uid');
        when(mockUserCredential.user).thenReturn(mockUser);
        when(mockAuthService.signInWithGoogle())
            .thenAnswer((_) async => mockUserCredential);
        when(mockUserRepository.getUserProfile('test-uid'))
            .thenAnswer((_) async => null);
        when(mockUserRepository.saveUserProfile(any))
            .thenAnswer((_) async {});

        // Act
        await viewModel.signInWithGoogle();

        // Assert
        expect(viewModel.state, AuthState.authenticated);
        expect(viewModel.errorMessage, null);
      });
    });

    group('Loading States', () {
      test('should show loading during sign in process', () async {
        // Arrange
        bool loadingStateObserved = false;
        viewModel.addListener(() {
          if (viewModel.isLoading) {
            loadingStateObserved = true;
          }
        });
        
        when(mockAuthService.signInWithGoogle())
            .thenAnswer((_) async {
          // Simulate delay
          await Future.delayed(const Duration(milliseconds: 100));
          return null;
        });

        // Act
        await viewModel.signInWithGoogle();

        // Assert
        expect(loadingStateObserved, true);
        expect(viewModel.isLoading, false); // Should be false after completion
      });
    });
  });
}