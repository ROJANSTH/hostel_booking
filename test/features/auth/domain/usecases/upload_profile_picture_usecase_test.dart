import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:hostel_booking/core/error/failures.dart';
import 'package:hostel_booking/features/auth/domain/repositories/auth_repository.dart';
import 'package:hostel_booking/features/auth/domain/usecases/upload_profile_picture_usecase.dart';

// ─── Mock ────────────────────────────────────────────────────────────────────
class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late UploadProfilePictureUseCase uploadProfilePictureUseCase;
  late MockAuthRepository mockRepository;

  const tFilePath = '/storage/image/profile.jpg';
  const tImageUrl = 'https://cdn.example.com/profile.jpg';

  // ── Setup ──────────────────────────────────────────────────────────────────
  setUp(() {
    mockRepository = MockAuthRepository();
    uploadProfilePictureUseCase =
        UploadProfilePictureUseCase(repository: mockRepository);
  });

  // ── Tests ──────────────────────────────────────────────────────────────────
  group('UploadProfilePictureUseCase', () {
    // Use-Case Test 5
    test(
      'should return image URL when upload succeeds',
      () async {
        // Arrange
        when(() => mockRepository.uploadProfilePicture(tFilePath))
            .thenAnswer((_) async => const Right(tImageUrl));

        // Act
        final result = await uploadProfilePictureUseCase(
          UploadProfilePictureParams(filePath: tFilePath),
        );

        // Assert
        expect(result, const Right(tImageUrl));
        verify(() => mockRepository.uploadProfilePicture(tFilePath)).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test(
      'should return ServerFailure when upload fails',
      () async {
        // Arrange
        const failure = ServerFailure('Upload failed');
        when(() => mockRepository.uploadProfilePicture(tFilePath))
            .thenAnswer((_) async => const Left(failure));

        // Act
        final result = await uploadProfilePictureUseCase(
          UploadProfilePictureParams(filePath: tFilePath),
        );

        // Assert
        expect(result, const Left(failure));
        verify(() => mockRepository.uploadProfilePicture(tFilePath)).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );
  });
}