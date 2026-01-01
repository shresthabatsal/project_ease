import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? authId;
  final String fullName;
  final String email;
  final String phone;
  final String password;

  const AuthEntity({
    this.authId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
  });

  @override
  List<Object?> get props => [
        authId,
        fullName,
        email,
        phone,
        password,
      ];
}