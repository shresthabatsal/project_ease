import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/features/profile/data/repositories/profile_repository.dart';
import 'package:project_ease/features/auth/domain/entities/auth_entity.dart';
import 'package:project_ease/features/profile/domain/repositories/profile_repository.dart';

final updateProfileUsecaseProvider = Provider<UpdateProfileUsecase>(
  (ref) => UpdateProfileUsecase(ref.read(profileRepositoryProvider)),
);

class UpdateProfileParams {
  final String? fullName;
  final String? phoneNumber;
  final String? email;
  final String? password;
  final String? profilePicturePath;
  final bool removeProfilePicture;

  const UpdateProfileParams({
    this.fullName,
    this.phoneNumber,
    this.email,
    this.password,
    this.profilePicturePath,
    this.removeProfilePicture = false,
  });
}

class UpdateProfileUsecase {
  final IProfileRepository _repo;
  UpdateProfileUsecase(this._repo);

  Future<Either<Failure, AuthEntity>> call(UpdateProfileParams params) =>
      _repo.updateProfile(
        fullName: params.fullName,
        phoneNumber: params.phoneNumber,
        email: params.email,
        password: params.password,
        profilePicturePath: params.profilePicturePath,
        removeProfilePicture: params.removeProfilePicture,
      );
}
