import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/core/usecases/app_usecase.dart';
import 'package:project_ease/features/auth/data/repositories/auth_repository.dart';
import 'package:project_ease/features/auth/domain/entities/auth_entity.dart';
import 'package:project_ease/features/auth/domain/repositories/auth_repository.dart';

class GoogleAuthParams extends Equatable {
  final String googleToken;
  const GoogleAuthParams({required this.googleToken});

  @override
  List<Object?> get props => [googleToken];
}

final googleAuthUsecaseProvider = Provider<GoogleAuthUsecase>((ref) {
  return GoogleAuthUsecase(authRepository: ref.read(authRepositoryProvider));
});

class GoogleAuthUsecase
    implements UsecaseWithParams<AuthEntity, GoogleAuthParams> {
  final IAuthRepository _authRepository;
  GoogleAuthUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, AuthEntity>> call(GoogleAuthParams params) {
    return _authRepository.googleAuth(params.googleToken);
  }
}
