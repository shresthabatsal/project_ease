import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/core/usecases/app_usecase.dart';
import 'package:project_ease/features/auth/domain/entities/auth_entity.dart';
import 'package:project_ease/features/profile/data/repositories/profile_repository.dart';
import 'package:project_ease/features/profile/domain/repositories/profile_repository.dart';

final getProfileUseCaseProvider = Provider<GetProfileUseCase>((ref) {
  final repository = ref.read(profileRepositoryProvider);
  return GetProfileUseCase(repository: repository);
});

class GetProfileUseCase implements UsecaseWithoutParams<AuthEntity> {
  final IProfileRepository repository;

  GetProfileUseCase({required this.repository});

  @override
  Future<Either<Failure, AuthEntity>> call() {
    return repository.getProfile();
  }
}
