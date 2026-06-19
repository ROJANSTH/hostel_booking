import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? id;
  final String name;
  final String email;
  final String password;
  final String phone;
  final String? profilePicture;

  const AuthEntity({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    this.profilePicture,
  });

  AuthEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    String? phone,
    String? profilePicture,
  }) {
    return AuthEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      profilePicture: profilePicture ?? this.profilePicture,
    );
  }

  @override
  List<Object?> get props => [id, name, email, password, phone, profilePicture];
}
