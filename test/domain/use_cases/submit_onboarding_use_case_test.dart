import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:chaosclinic/domain/use_cases/submit_onboarding_use_case.dart';
import 'package:chaosclinic/data/repositories/user_repository.dart';

// Generate mocks
@GenerateMocks([UserRepository])
import 'submit_onboarding_use_case_test.mocks.dart';

void main() {
  group('SubmitOnboardingUseCase', () {
    late SubmitOnboardingUseCase useCase;
    late MockUserRepository mockUserRepository;

    setUp(() {
      mockUserRepository = MockUserRepository();
      useCase = SubmitOnboardingUseCase(mockUserRepository);
    });

    group('Successful Submission', () {
      test('should successfully submit complete onboarding data', () async {
        // Arrange
        when(mockUserRepository.updateUserProfile(any, any))
            .thenAnswer((_) async {});

        // Act
        final result = await useCase.call(
          userId: 'test-user-id',
          copingPreference: 'Meditation & Mindfulness',
          trustedContactName: 'John Doe',
          trustedContactPhone: '+1-555-123-4567',
          trustedContactEmail: 'john@example.com',
          trustedContactRelationship: 'Friend',
        );

        // Assert
        expect(result, isTrue);
        
        final captured = verify(mockUserRepository.updateUserProfile(
          'test-user-id',
          captureAny,
        )).captured.single as Map<String, dynamic>;
        
        expect(captured['copingPreference'], 'Meditation & Mindfulness');
        expect(captured['hasCompletedOnboarding'], true);
        expect(captured['supportContacts'], isA<List>());
        expect(captured['updatedAt'], isNotNull);
      });

      test('should submit with phone number only', () async {
        // Arrange
        when(mockUserRepository.updateUserProfile(any, any))
            .thenAnswer((_) async {});

        // Act
        final result = await useCase.call(
          userId: 'test-user-id',
          copingPreference: 'Physical Exercise',
          trustedContactName: 'Jane Smith',
          trustedContactPhone: '555-123-4567',
          trustedContactRelationship: 'Family',
        );

        // Assert
        expect(result, isTrue);
        verify(mockUserRepository.updateUserProfile(any, any)).called(1);
      });

      test('should submit with email only', () async {
        // Arrange
        when(mockUserRepository.updateUserProfile(any, any))
            .thenAnswer((_) async {});

        // Act
        final result = await useCase.call(
          userId: 'test-user-id',
          copingPreference: 'Journaling & Writing',
          trustedContactName: 'Alex Johnson',
          trustedContactEmail: 'alex@example.com',
          trustedContactRelationship: 'Partner',
        );

        // Assert
        expect(result, isTrue);
        verify(mockUserRepository.updateUserProfile(any, any)).called(1);
      });

      test('should handle minimal required data', () async {
        // Arrange
        when(mockUserRepository.updateUserProfile(any, any))
            .thenAnswer((_) async {});

        // Act
        final result = await useCase.call(
          userId: 'test-user-id',
          copingPreference: 'Music & Arts',
          trustedContactName: 'Sam Wilson',
          trustedContactPhone: '1234567890',
        );

        // Assert
        expect(result, isTrue);
        
        final captured = verify(mockUserRepository.updateUserProfile(
          'test-user-id',
          captureAny,
        )).captured.single as Map<String, dynamic>;
        
        final supportContacts = captured['supportContacts'] as List;
        final contact = supportContacts.first;
        
        expect(contact['name'], 'Sam Wilson');
        expect(contact['relationship'], 'Friend'); // Default value
        expect(contact['isPrimary'], true);
      });
    });

    group('Validation Failures', () {
      test('should fail with empty coping preference', () async {
        // Act
        final result = await useCase.call(
          userId: 'test-user-id',
          copingPreference: '',
          trustedContactName: 'John Doe',
          trustedContactPhone: '555-123-4567',
        );

        // Assert
        expect(result, isFalse);
        verifyNever(mockUserRepository.updateUserProfile(any, any));
      });

      test('should fail with whitespace-only coping preference', () async {
        // Act
        final result = await useCase.call(
          userId: 'test-user-id',
          copingPreference: '   ',
          trustedContactName: 'John Doe',
          trustedContactPhone: '555-123-4567',
        );

        // Assert
        expect(result, isFalse);
        verifyNever(mockUserRepository.updateUserProfile(any, any));
      });

      test('should fail with empty trusted contact name', () async {
        // Act
        final result = await useCase.call(
          userId: 'test-user-id',
          copingPreference: 'Meditation & Mindfulness',
          trustedContactName: '',
          trustedContactPhone: '555-123-4567',
        );

        // Assert
        expect(result, isFalse);
        verifyNever(mockUserRepository.updateUserProfile(any, any));
      });

      test('should fail with short trusted contact name', () async {
        // Act
        final result = await useCase.call(
          userId: 'test-user-id',
          copingPreference: 'Meditation & Mindfulness',
          trustedContactName: 'A',
          trustedContactPhone: '555-123-4567',
        );

        // Assert
        expect(result, isFalse);
        verifyNever(mockUserRepository.updateUserProfile(any, any));
      });

      test('should fail with no contact information', () async {
        // Act
        final result = await useCase.call(
          userId: 'test-user-id',
          copingPreference: 'Meditation & Mindfulness',
          trustedContactName: 'John Doe',
        );

        // Assert
        expect(result, isFalse);
        verifyNever(mockUserRepository.updateUserProfile(any, any));
      });

      test('should fail with empty contact information', () async {
        // Act
        final result = await useCase.call(
          userId: 'test-user-id',
          copingPreference: 'Meditation & Mindfulness',
          trustedContactName: 'John Doe',
          trustedContactPhone: '',
          trustedContactEmail: '',
        );

        // Assert
        expect(result, isFalse);
        verifyNever(mockUserRepository.updateUserProfile(any, any));
      });

      test('should fail with whitespace-only contact information', () async {
        // Act
        final result = await useCase.call(
          userId: 'test-user-id',
          copingPreference: 'Meditation & Mindfulness',
          trustedContactName: 'John Doe',
          trustedContactPhone: '   ',
          trustedContactEmail: '   ',
        );

        // Assert
        expect(result, isFalse);
        verifyNever(mockUserRepository.updateUserProfile(any, any));
      });

      test('should fail with invalid email format', () async {
        // Act
        final result = await useCase.call(
          userId: 'test-user-id',
          copingPreference: 'Meditation & Mindfulness',
          trustedContactName: 'John Doe',
          trustedContactEmail: 'invalid-email',
        );

        // Assert
        expect(result, isFalse);
        verifyNever(mockUserRepository.updateUserProfile(any, any));
      });

      test('should fail with invalid phone format', () async {
        // Act
        final result = await useCase.call(
          userId: 'test-user-id',
          copingPreference: 'Meditation & Mindfulness',
          trustedContactName: 'John Doe',
          trustedContactPhone: '123', // Too short
        );

        // Assert
        expect(result, isFalse);
        verifyNever(mockUserRepository.updateUserProfile(any, any));
      });
    });

    group('Email Validation', () {
      test('should accept valid email formats', () async {
        when(mockUserRepository.updateUserProfile(any, any))
            .thenAnswer((_) async {});

        final validEmails = [
          'test@example.com',
          'user.name@domain.co.uk',
          'user+tag@example.org',
          'firstname.lastname@company.com',
        ];

        for (final email in validEmails) {
          final result = await useCase.call(
            userId: 'test-user-id',
            copingPreference: 'Meditation & Mindfulness',
            trustedContactName: 'John Doe',
            trustedContactEmail: email,
          );
          
          expect(result, isTrue, reason: 'Email $email should be valid');
        }
      });

      test('should reject invalid email formats', () async {
        final invalidEmails = [
          'invalid',
          '@example.com',
          'user@',
          'user@.com',
          'user.example.com',
          'user@example',
        ];

        for (final email in invalidEmails) {
          final result = await useCase.call(
            userId: 'test-user-id',
            copingPreference: 'Meditation & Mindfulness',
            trustedContactName: 'John Doe',
            trustedContactEmail: email,
          );
          
          expect(result, isFalse, reason: 'Email $email should be invalid');
        }
      });
    });

    group('Phone Validation', () {
      test('should accept valid phone formats', () async {
        when(mockUserRepository.updateUserProfile(any, any))
            .thenAnswer((_) async {});

        final validPhones = [
          '5551234567',
          '+1-555-123-4567',
          '(555) 123-4567',
          '+44 20 7946 0958',
          '1234567890',
          '123-456-7890',
        ];

        for (final phone in validPhones) {
          final result = await useCase.call(
            userId: 'test-user-id',
            copingPreference: 'Meditation & Mindfulness',
            trustedContactName: 'John Doe',
            trustedContactPhone: phone,
          );
          
          expect(result, isTrue, reason: 'Phone $phone should be valid');
        }
      });

      test('should reject invalid phone formats', () async {
        final invalidPhones = [
          '123',
          'abc123',
          '123abc',
          '1234567890123456', // Too long
          '123456', // Too short
        ];

        for (final phone in invalidPhones) {
          final result = await useCase.call(
            userId: 'test-user-id',
            copingPreference: 'Meditation & Mindfulness',
            trustedContactName: 'John Doe',
            trustedContactPhone: phone,
          );
          
          expect(result, isFalse, reason: 'Phone $phone should be invalid');
        }
      });
    });

    group('Repository Error Handling', () {
      test('should return false when repository throws exception', () async {
        // Arrange
        when(mockUserRepository.updateUserProfile(any, any))
            .thenThrow(Exception('Database error'));

        // Act
        final result = await useCase.call(
          userId: 'test-user-id',
          copingPreference: 'Meditation & Mindfulness',
          trustedContactName: 'John Doe',
          trustedContactPhone: '555-123-4567',
        );

        // Assert
        expect(result, isFalse);
      });

      test('should handle network connectivity issues', () async {
        // Arrange
        when(mockUserRepository.updateUserProfile(any, any))
            .thenThrow(Exception('Network error'));

        // Act
        final result = await useCase.call(
          userId: 'test-user-id',
          copingPreference: 'Physical Exercise',
          trustedContactName: 'Jane Smith',
          trustedContactEmail: 'jane@example.com',
        );

        // Assert
        expect(result, isFalse);
      });
    });

    group('Data Trimming and Sanitization', () {
      test('should trim whitespace from inputs', () async {
        // Arrange
        when(mockUserRepository.updateUserProfile(any, any))
            .thenAnswer((_) async {});

        // Act
        await useCase.call(
          userId: 'test-user-id',
          copingPreference: 'Meditation & Mindfulness',
          trustedContactName: '  John Doe  ',
          trustedContactPhone: '  555-123-4567  ',
          trustedContactEmail: '  john@example.com  ',
        );

        // Assert
        final captured = verify(mockUserRepository.updateUserProfile(
          'test-user-id',
          captureAny,
        )).captured.single as Map<String, dynamic>;
        
        final supportContacts = captured['supportContacts'] as List;
        final contact = supportContacts.first;
        
        expect(contact['name'], 'John Doe');
        expect(contact['phoneNumber'], '555-123-4567');
        expect(contact['email'], 'john@example.com');
      });
    });
  });
}