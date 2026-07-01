import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:hostel_booking/core/error/failures.dart';
import 'package:hostel_booking/features/auth/domain/repositories/auth_repository.dart';
import 'package:hostel_booking/features/auth/domain/usecases/logout_usecase.dart';

// ─── Mock ────────────────────────────────────────────────────────────────────
class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late LogoutUseCase logoutUseCase;
  late MockAuthRepository mockRepository;

  const tEmail = 'test@example.com';

  // ── Setup ──────────────────────────────────────────────────────────────────
  setUp(() {
    mockRepository = MockAuthRepository();
    logoutUseCase = LogoutUseCase(repository: mockRepository);
  });

  // ── Tests ──────────────────────────────────────────────────────────────────
  group('LogoutUseCase', () {
    // Use-Case Test 4
    test(
      'should return true when repository logout succeeds',
      () async {
        // Arrange
        when(() => mockRepository.logout(tEmail))
            .thenAnswer((_) async => const Right(true));

        // Act
        final result = await logoutUseCase(tEmail);

        // Assert
        expect(result, const Right(true));
        verify(() => mockRepository.logout(tEmail)).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test(
      'should return ServerFailure when repository logout fails',
      () async {
        // Arrange
        const failure = ServerFailure('Logout failed');
        when(() => mockRepository.logout(tEmail))
            .thenAnswer((_) async => const Left(failure));

        // Act
        final result = await logoutUseCase(tEmail);

        // Assert
        expect(result, const Left(failure));
        verify(() => mockRepository.logout(tEmail)).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );
  });
}