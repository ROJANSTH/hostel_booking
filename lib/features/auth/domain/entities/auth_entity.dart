import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String name;
  final String email;
  final String password;
  final String phone;

  const AuthEntity({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
  });

  @override
  List<Object?> get props => [name, email, password, phone];
}
