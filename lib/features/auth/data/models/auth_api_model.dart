
import 'package:project_ease/features/auth/domain/entities/auth_entity.dart';

class AuthApiModel {
  final String? id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? password;
  final String? profilePicture;

  AuthApiModel({
    this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.password,
    this.profilePicture
  });

  // To Json
  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'password': password,
      'profilePicture': profilePicture,
    };
  }

  // From Json
  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      id: json['_id'],
      fullName: json['fullName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      profilePicture: json['profilePictureUrl'],
    );
  }

  // To Entity
  AuthEntity toEntity() {
    return AuthEntity(
      authId: id,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      profilePicture: profilePicture,
    );
  }

  // From Entity
  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      id: entity.authId,
      fullName: entity.fullName,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      password: entity.password,
      profilePicture: entity.profilePicture,
    );
  }

  // To Entity List
  static List<AuthEntity> toEntityList(List<AuthApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}