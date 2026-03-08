import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/features/auth/data/repositories/auth_repository.dart';
import 'package:project_ease/features/auth/domain/entities/auth_entity.dart';
import 'package:project_ease/features/auth/domain/repositories/auth_repository.dart';

final googleLoginUsecaseProvider = Provider<GoogleLoginUsecase>((ref) {
  return GoogleLoginUsecase(authRepository: ref.read(authRepositoryProvider));
});

class GoogleLoginUsecase {
  final IAuthRepository _authRepository;
  GoogleLoginUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  Future<Either<Failure, AuthEntity>> call(String idToken) =>
      _authRepository.googleLogin(idToken);
}
