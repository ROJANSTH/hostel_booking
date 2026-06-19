import 'package:hostel_booking/core/api/api_client.dart';
import 'package:hostel_booking/core/api/api_endpoints.dart';
import 'package:hostel_booking/features/auth/data/models/auth_api_model.dart';

abstract class IAuthApiDataSource {
  Future<RegisterResponse> register(RegisterRequest request);
  Future<LoginResponse> login(LoginRequest request);
}

class AuthApiDataSource implements IAuthApiDataSource {
  final ApiClient _apiClient;

  AuthApiDataSource({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<RegisterResponse> register(RegisterRequest request) async {
    final response = await _apiClient.post(
      ApiEndpoints.register,
      body: request.toJson(),
    );
    return RegisterResponse.fromJson(response);
  }

  @override
  Future<LoginResponse> login(LoginRequest request) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      body: request.toJson(),
    );
    return LoginResponse.fromJson(response);
  }
}
