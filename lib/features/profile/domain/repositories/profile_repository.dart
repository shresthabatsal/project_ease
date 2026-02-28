import 'package:dartz/dartz.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/features/auth/domain/entities/auth_entity.dart';

abstract interface class IProfileRepository {
  Future<Either<Failure, AuthEntity>> getProfile();

  Future<Either<Failure, AuthEntity>> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? email,
    String? password,
    String? profilePicturePath,
    bool removeProfilePicture,
  });
}
