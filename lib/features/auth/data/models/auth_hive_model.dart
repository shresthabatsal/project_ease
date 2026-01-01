import 'package:hive_flutter/hive_flutter.dart';
import 'package:project_ease/core/constants/hive_table_constant.dart';
import 'package:project_ease/features/auth/domain/entities/auth_entity.dart';
import 'package:uuid/uuid.dart';

part 'auth_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.userTypeId)
class AuthHiveModel extends HiveObject {
  @HiveField(0)
  final String? authId;

  @HiveField(1)
  final String fullName;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String? phoneNumber;

  @HiveField(4)
  final String? password;


  AuthHiveModel({
    String? authId,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.password,
  }) : authId = authId ?? const Uuid().v4();

  // To Entity
  AuthEntity toEntity({AuthEntity? auth}) {
    return AuthEntity(
      authId: authId,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
    );
  }

  // From Entity
  factory AuthHiveModel.fromEntity(AuthEntity entity) {
    return AuthHiveModel(
      authId: entity.authId,
      fullName: entity.fullName,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      password: entity.password,
    );
  }

  // To Entity List
  static List<AuthEntity> toEntityList(List<AuthHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}