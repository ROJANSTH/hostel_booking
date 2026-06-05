import 'package:dartz/dartz.dart';
import 'package:hostel_booking/core/error/failures.dart';
import 'package:hostel_booking/features/auth/domain/entities/auth_entity.dart';

abstract class IAuthRepository {
  Future<Either<Failure, bool>> register(AuthEntity entity);
  Future<Either<Failure, AuthEntity>> login(String email, String password);
  Future<Either<Failure, bool>> logout(String email);
}
