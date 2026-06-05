import 'package:dartz/dartz.dart';
import 'package:hostel_booking/core/error/failures.dart';
import 'package:hostel_booking/core/usecases/app_usecase.dart';
import 'package:hostel_booking/features/auth/domain/entities/auth_entity.dart';
import 'package:hostel_booking/features/auth/domain/repositories/auth_repository.dart';

class LoginParams {
  final String email;
  final String password;

  LoginParams({required this.email, required this.password});
}

class LoginUseCase
    implements UseCase<Either<Failure, AuthEntity>, LoginParams> {
  final IAuthRepository _repository;

  LoginUseCase({required IAuthRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, AuthEntity>> call(LoginParams params) =>
      _repository.login(params.email, params.password);
}
