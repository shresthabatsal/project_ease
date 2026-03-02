import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/services/google/google_sign_in_service.dart';
import 'package:project_ease/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:project_ease/features/auth/domain/usecases/google_auth_usecase.dart';
import 'package:project_ease/features/auth/domain/usecases/login_usecase.dart';
import 'package:project_ease/features/auth/domain/usecases/logout_usecase.dart';
import 'package:project_ease/features/auth/domain/usecases/register_usecase.dart';
import 'package:project_ease/features/auth/presentation/state/auth_state.dart';

// Provider
final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(() {
  return AuthViewModel();
});

class AuthViewModel extends Notifier<AuthState> {
  late final RegisterUsecase _registerUsecase;
  late final LoginUsecase _loginUsecase;
  late final LogoutUsecase _logoutUsecase;
  late final ForgotPasswordUsecase _forgotPasswordUsecase;
  late final GoogleSignInService _googleSignInService;
  late final GoogleAuthUsecase _googleAuthUsecase;

  @override
  AuthState build() {
    _registerUsecase = ref.read(registerUsecaseProvider);
    _loginUsecase = ref.read(loginUsecaseProvider);
    _logoutUsecase = ref.read(logoutUsecaseProvider);
    _forgotPasswordUsecase = ref.read(forgotPasswordUsecaseProvider);
    _googleSignInService = ref.read(googleSignInServiceProvider);
    _googleAuthUsecase = ref.read(googleAuthUsecaseProvider);
    return AuthState();
  }

  Future<void> register({
    required String fullName,
    required String email,
    String? phoneNumber,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    // await Future.delayed(const Duration(seconds: 2)); // Simulate delay
    final result = await _registerUsecase(
      RegisterUsecaseParams(
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
      ),
    );
    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (success) {
        state = state.copyWith(status: AuthStatus.registered);
      },
    );
  }

  // Login
  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading);
    // await Future.delayed(const Duration(seconds: 2)); // Simulate delay
    final result = await _loginUsecase(
      LoginUsecaseParams(email: email, password: password),
    );
    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (authEntity) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          authEntity: authEntity,
        );
      },
    );
  }

  // Logout
  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _logoutUsecase();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (success) {
        if (success) {
          state = state.copyWith(
            status: AuthStatus.unauthenticated,
            authEntity: null,
          );
        } else {
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: "Logout Failed.",
          );
        }
      },
    );
  }

  // Forgot Password
  Future<void> forgotPassword({required String email}) async {
    state = state.copyWith(status: AuthStatus.loading);
    final result = await _forgotPasswordUsecase(
      ForgotPasswordParams(email: email),
    );
    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(status: AuthStatus.passwordResetSent),
    );
  }

  Future<void> loginWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading);

    final idToken = await _googleSignInService.getIdToken();
    if (idToken == null) {
      // User cancelled, reset to initial quietly
      state = state.copyWith(status: AuthStatus.initial);
      return;
    }

    final result = await _googleAuthUsecase(
      GoogleAuthParams(googleToken: idToken),
    );
    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (authEntity) => state = state.copyWith(
        status: AuthStatus.authenticated,
        authEntity: authEntity,
      ),
    );
  }
}
