import 'package:hostel_booking/features/auth/domain/entities/auth_entity.dart';

class RegisterRequest {
  final String fullName;
  final String email;
  final String password;
  final String phoneNumber;

  const RegisterRequest({
    required this.fullName,
    required this.email,
    required this.password,
    required this.phoneNumber,
  });

  factory RegisterRequest.fromEntity(AuthEntity entity) => RegisterRequest(
        fullName: entity.name,
        email: entity.email,
        password: entity.password,
        phoneNumber: entity.phone,
      );

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'email': email,
        'password': password,
        'phoneNumber': phoneNumber,
      };
}

class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}

class AuthUserModel {
  final String? id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? profilePicture;

  const AuthUserModel({
    this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.profilePicture,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) => AuthUserModel(
        id: json['_id']?.toString() ?? json['id']?.toString(),
        fullName: json['fullName']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        phoneNumber: json['phoneNumber']?.toString() ?? '',
        profilePicture: json['profilePicture']?.toString(),
      );

  AuthEntity toEntity({String password = ''}) => AuthEntity(
        id: id,
        name: fullName,
        email: email,
        password: password,
        phone: phoneNumber,
        profilePicture: profilePicture,
      );
}

class LoginResponse {
  final bool success;
  final String token;
  final AuthUserModel user;

  const LoginResponse({
    required this.success,
    required this.token,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        success: json['success'] == true,
        token: json['token']?.toString() ?? '',
        user: AuthUserModel.fromJson(
          json['data'] as Map<String, dynamic>? ?? {},
        ),
      );
}

class RegisterResponse {
  final bool success;
  final AuthUserModel user;

  const RegisterResponse({
    required this.success,
    required this.user,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) =>
      RegisterResponse(
        success: json['success'] == true,
        user: AuthUserModel.fromJson(
          json['data'] as Map<String, dynamic>? ?? {},
        ),
      );
}
