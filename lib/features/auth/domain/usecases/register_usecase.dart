import 'package:dartz/dartz.dart';
import 'package:hostel_booking/core/error/failures.dart';
import 'package:hostel_booking/core/usecases/app_usecase.dart';
import 'package:hostel_booking/features/auth/domain/entities/auth_entity.dart';
import 'package:hostel_booking/features/auth/domain/repositories/auth_repository.dart';

class RegisterUseCase implements UseCase<Either<Failure, bool>, AuthEntity> {
  final IAuthRepository _repository;

  RegisterUseCase({required IAuthRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, bool>> call(AuthEntity params) =>
      _repository.register(params);
}
