import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/features/auth/domain/entities/auth_entity.dart';
import 'package:project_ease/features/profile/data/repositories/profile_repository.dart';
import 'package:project_ease/features/profile/domain/repositories/profile_repository.dart';

final getProfileUsecaseProvider = Provider<GetProfileUsecase>(
  (ref) => GetProfileUsecase(ref.read(profileRepositoryProvider)),
);

class GetProfileUsecase {
  final IProfileRepository _repo;
  GetProfileUsecase(this._repo);
  Future<Either<Failure, AuthEntity>> call() => _repo.getProfile();
}