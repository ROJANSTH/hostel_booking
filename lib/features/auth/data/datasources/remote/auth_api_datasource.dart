import 'package:dio/dio.dart';
import 'package:hostel_booking/core/api/api_client.dart';
import 'package:hostel_booking/core/api/api_endpoints.dart';
import 'package:hostel_booking/features/auth/data/models/auth_api_model.dart';

abstract class IAuthApiDataSource {
  Future<RegisterResponse> register(RegisterRequest request);
  Future<LoginResponse> login(LoginRequest request);
  Future<String> uploadProfilePicture(String filePath, String token);
}

class AuthApiDataSource implements IAuthApiDataSource {
  final ApiClient _apiClient;
  final Dio _dio;

  AuthApiDataSource({required ApiClient apiClient, Dio? dio})
      : _apiClient = apiClient,
        _dio = dio ?? Dio();

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

  @override
  Future<String> uploadProfilePicture(String filePath, String token) async {
    try {
      final fileName = filePath.split('/').last;
      final formData = FormData.fromMap({
        'profilePicture': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        ApiEndpoints.uploadProfilePicture,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['success'] == true) {
          final profilePicture = responseData['data']['profilePicture']?.toString();
          if (profilePicture != null) {
            return profilePicture;
          }
        }
      }

      throw ApiException(
        statusCode: response.statusCode ?? 500,
        message: response.data?['message']?.toString() ?? 'Profile upload failed',
      );
    } on DioException catch (e) {
      throw ApiException(
        statusCode: e.response?.statusCode ?? 500,
        message: e.response?.data?['message']?.toString() ?? e.message ?? 'Network error during upload',
      );
    }
  }
}
