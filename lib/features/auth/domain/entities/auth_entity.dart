import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? id;
  final String name;
  final String email;
  final String password;
  final String phone;

  const AuthEntity({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
  });

  @override
  List<Object?> get props => [id, name, email, password, phone];
}
