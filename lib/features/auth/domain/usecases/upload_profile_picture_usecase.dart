import 'package:dartz/dartz.dart';
import 'package:hostel_booking/core/error/failures.dart';
import 'package:hostel_booking/core/usecases/app_usecase.dart';
import 'package:hostel_booking/features/auth/domain/repositories/auth_repository.dart';

class UploadProfilePictureParams {
  final String filePath;

  UploadProfilePictureParams({required this.filePath});
}

class UploadProfilePictureUseCase
    implements UseCase<Either<Failure, String>, UploadProfilePictureParams> {
  final IAuthRepository _repository;

  UploadProfilePictureUseCase({required IAuthRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, String>> call(UploadProfilePictureParams params) =>
      _repository.uploadProfilePicture(params.filePath);
}
