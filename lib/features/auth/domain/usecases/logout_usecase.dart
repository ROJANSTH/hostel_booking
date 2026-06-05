import 'package:dartz/dartz.dart';
import 'package:hostel_booking/core/error/failures.dart';
import 'package:hostel_booking/core/usecases/app_usecase.dart';
import 'package:hostel_booking/features/auth/domain/repositories/auth_repository.dart';

class LogoutUseCase implements UseCase<Either<Failure, bool>, String> {
  final IAuthRepository _repository;

  LogoutUseCase({required IAuthRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, bool>> call(String email) => _repository.logout(email);
}
