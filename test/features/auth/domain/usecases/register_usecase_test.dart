import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:hostel_booking/core/error/failures.dart';
import 'package:hostel_booking/features/auth/domain/entities/auth_entity.dart';
import 'package:hostel_booking/features/auth/domain/repositories/auth_repository.dart';
import 'package:hostel_booking/features/auth/domain/usecases/register_usecase.dart';

// ─── Mock ────────────────────────────────────────────────────────────────────
class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late RegisterUseCase registerUseCase;
  late MockAuthRepository mockRepository;

  // ── Test data ──────────────────────────────────────────────────────────────
  const tAuthEntity = AuthEntity(
    id: null,
    name: 'John Doe',
    email: 'john@example.com',
    password: 'secret123',
    phone: '9800000001',
  );

  // ── Setup ──────────────────────────────────────────────────────────────────
  setUp(() {
    mockRepository = MockAuthRepository();
    registerUseCase = RegisterUseCase(repository: mockRepository);

    // Provide a fallback value for AuthEntity (used by mocktail matchers)
    registerFallbackValue(tAuthEntity);
  });

  // ── Tests ──────────────────────────────────────────────────────────────────
  group('RegisterUseCase', () {
    // Use-Case Test 3
    test(
      'should return true when repository register succeeds',
      () async {
        // Arrange
        when(() => mockRepository.register(any()))
            .thenAnswer((_) async => const Right(true));

        // Act
        final result = await registerUseCase(tAuthEntity);

        // Assert
        expect(result, const Right(true));
        verify(() => mockRepository.register(tAuthEntity)).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test(
      'should return ServerFailure when repository register fails',
      () async {
        // Arrange
        const failure = ServerFailure('Email already exists');
        when(() => mockRepository.register(any()))
            .thenAnswer((_) async => const Left(failure));

        // Act
        final result = await registerUseCase(tAuthEntity);

        // Assert
        expect(result, const Left(failure));
        verify(() => mockRepository.register(tAuthEntity)).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );
  });
}