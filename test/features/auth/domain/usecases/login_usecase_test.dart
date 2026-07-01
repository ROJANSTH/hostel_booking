import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:hostel_booking/core/error/failures.dart';
import 'package:hostel_booking/features/auth/domain/entities/auth_entity.dart';
import 'package:hostel_booking/features/auth/domain/repositories/auth_repository.dart';
import 'package:hostel_booking/features/auth/domain/usecases/login_usecase.dart';

// ─── Mock ────────────────────────────────────────────────────────────────────
class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late LoginUseCase loginUseCase;
  late MockAuthRepository mockRepository;

  // ── Test data ──────────────────────────────────────────────────────────────
  const email = 'test@example.com';
  const password = 'password123';

  final tAuthEntity = AuthEntity(
    id: '1',
    name: 'Test User',
    email: email,
    password: password,
    phone: '9800000000',
  );

  // ── Setup ──────────────────────────────────────────────────────────────────
  setUp(() {
    mockRepository = MockAuthRepository();
    loginUseCase = LoginUseCase(repository: mockRepository);
  });

  // ── Tests ──────────────────────────────────────────────────────────────────
  group('LoginUseCase', () {
    // Use-Case Test 1
    test(
      'should return AuthEntity when repository login succeeds',
      () async {
        // Arrange
        when(() => mockRepository.login(email, password))
            .thenAnswer((_) async => Right(tAuthEntity));

        // Act
        final result =
            await loginUseCase(LoginParams(email: email, password: password));

        // Assert
        expect(result, Right(tAuthEntity));
        verify(() => mockRepository.login(email, password)).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    // Use-Case Test 2
    test(
      'should return ServerFailure when repository login fails',
      () async {
        // Arrange
        const failure = ServerFailure('Invalid credentials');
        when(() => mockRepository.login(email, password))
            .thenAnswer((_) async => const Left(failure));

        // Act
        final result =
            await loginUseCase(LoginParams(email: email, password: password));

        // Assert
        expect(result, const Left(failure));
        verify(() => mockRepository.login(email, password)).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );
  });
}
