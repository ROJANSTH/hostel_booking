import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hostel_booking/core/api/api_client.dart';
import 'package:hostel_booking/core/providers/shared_prefs_provider.dart';
import 'package:hostel_booking/core/services/storage/storage_service.dart';
import 'package:hostel_booking/features/auth/data/datasources/remote/auth_api_datasource.dart';
import 'package:hostel_booking/features/auth/data/repositories/auth_repository.dart';
import 'package:hostel_booking/features/auth/domain/entities/auth_entity.dart';
import 'package:hostel_booking/features/auth/domain/repositories/auth_repository.dart';
import 'package:hostel_booking/features/auth/domain/usecases/login_usecase.dart';
import 'package:hostel_booking/features/auth/domain/usecases/logout_usecase.dart';
import 'package:hostel_booking/features/auth/domain/usecases/register_usecase.dart';
import 'package:hostel_booking/features/auth/presentation/view_model/auth_state.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService(prefs: ref.read(sharedPreferencesProvider));
});

final authApiDataSourceProvider = Provider<IAuthApiDataSource>((ref) {
  return AuthApiDataSource(apiClient: ref.read(apiClientProvider));
});

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepositoryImpl(
    apiDataSource: ref.read(authApiDataSourceProvider),
    storageService: ref.read(storageServiceProvider),
  );
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(repository: ref.read(authRepositoryProvider));
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(repository: ref.read(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(repository: ref.read(authRepositoryProvider));
});

final authViewModelProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    registerUseCase: ref.read(registerUseCaseProvider),
    loginUseCase: ref.read(loginUseCaseProvider),
    logoutUseCase: ref.read(logoutUseCaseProvider),
    storageService: ref.read(storageServiceProvider),
  );
});

class AuthNotifier extends StateNotifier<AuthState> {
  final RegisterUseCase _registerUseCase;
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final StorageService _storageService;

  AuthNotifier({
    required RegisterUseCase registerUseCase,
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required StorageService storageService,
  })  : _registerUseCase = registerUseCase,
        _loginUseCase = loginUseCase,
        _logoutUseCase = logoutUseCase,
        _storageService = storageService,
        super(AuthState(user: storageService.getSavedUser()));

  Future<void> register(AuthEntity entity) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _registerUseCase(entity);
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (_) => state = state.copyWith(isLoading: false, isSuccess: true),
    );
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    final result =
        await _loginUseCase(LoginParams(email: email, password: password));
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (user) =>
          state = state.copyWith(isLoading: false, isSuccess: true, user: user),
    );
  }

  Future<void> logout(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _logoutUseCase(email);
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (_) => state = const AuthState(),
    );
  }

  void resetState() => state = AuthState(user: _storageService.getSavedUser());
}
