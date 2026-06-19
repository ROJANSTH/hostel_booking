import 'package:dartz/dartz.dart';
import 'package:hostel_booking/core/api/api_client.dart';
import 'package:hostel_booking/core/error/failures.dart';
import 'package:hostel_booking/core/services/storage/storage_service.dart';
import 'package:hostel_booking/features/auth/data/datasources/remote/auth_api_datasource.dart';
import 'package:hostel_booking/features/auth/data/models/auth_api_model.dart';
import 'package:hostel_booking/features/auth/domain/entities/auth_entity.dart';
import 'package:hostel_booking/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final IAuthApiDataSource _apiDataSource;
  final StorageService _storageService;

  AuthRepositoryImpl({
    required IAuthApiDataSource apiDataSource,
    required StorageService storageService,
  })  : _apiDataSource = apiDataSource,
        _storageService = storageService;

  @override
  Future<Either<Failure, bool>> register(AuthEntity entity) async {
    try {
      await _apiDataSource.register(RegisterRequest.fromEntity(entity));
      return const Right(true);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(
      String email, String password) async {
    try {
      final response = await _apiDataSource.login(
        LoginRequest(email: email, password: password),
      );
      await _storageService.saveToken(response.token);
      await _storageService.saveUser(response.user);
      return Right(response.user.toEntity());
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logout(String email) async {
    try {
      await _storageService.clearSession();
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadProfilePicture(String filePath) async {
    try {
      final token = _storageService.getToken();
      if (token == null || token.isEmpty) {
        return Left(const ServerFailure('Authentication token not found'));
      }
      final imageUrl = await _apiDataSource.uploadProfilePicture(filePath, token);
      await _storageService.saveProfilePicture(imageUrl);
      return Right(imageUrl);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
