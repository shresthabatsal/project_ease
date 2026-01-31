import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/core/usecases/app_usecase.dart';
import 'package:project_ease/features/auth/domain/entities/auth_entity.dart';
import 'package:project_ease/features/profile/data/repositories/profile_repository.dart';
import 'package:project_ease/features/profile/domain/repositories/profile_repository.dart';

final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  final repository = ref.read(profileRepositoryProvider);
  return UpdateProfileUseCase(repository: repository);
});

class UpdateProfileUseCase
    implements UsecaseWithParams<AuthEntity, AuthEntity> {
  final IProfileRepository repository;

  UpdateProfileUseCase({required this.repository});

  @override
  Future<Either<Failure, AuthEntity>> call(AuthEntity updatedProfile) {
    return repository.updateProfile(updatedProfile);
  }
}
