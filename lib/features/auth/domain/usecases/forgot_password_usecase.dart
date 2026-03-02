import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/core/usecases/app_usecase.dart';
import 'package:project_ease/features/auth/data/repositories/auth_repository.dart';
import 'package:project_ease/features/auth/domain/repositories/auth_repository.dart';

class ForgotPasswordParams extends Equatable {
  final String email;
  const ForgotPasswordParams({required this.email});

  @override
  List<Object?> get props => [email];
}

final forgotPasswordUsecaseProvider = Provider<ForgotPasswordUsecase>((ref) {
  return ForgotPasswordUsecase(
    authRepository: ref.read(authRepositoryProvider),
  );
});

class ForgotPasswordUsecase
    implements UsecaseWithParams<bool, ForgotPasswordParams> {
  final IAuthRepository _authRepository;
  ForgotPasswordUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(ForgotPasswordParams params) {
    return _authRepository.sendPasswordResetEmail(params.email);
  }
}
