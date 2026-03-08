import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
  late final GoogleLoginUsecase _googleLoginUsecase;
  late final GoogleSignIn _googleSignIn;

  @override
  AuthState build() {
    _registerUsecase = ref.read(registerUsecaseProvider);
    _loginUsecase = ref.read(loginUsecaseProvider);
    _logoutUsecase = ref.read(logoutUsecaseProvider);
    _forgotPasswordUsecase = ref.read(forgotPasswordUsecaseProvider);
    _googleLoginUsecase = ref.read(googleLoginUsecaseProvider);
    _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId:
        '327888188050-dfdv01qj9c665eean12sqma0hnqrigtl.apps.googleusercontent.com',
  );
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
    try {
      // Always show account picker
      await _googleSignIn.signOut();

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled
        state = state.copyWith(status: AuthStatus.unauthenticated);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage:
              'Failed to get Google ID token. Check your OAuth client ID configuration.',
        );
        return;
      }

      final result = await _googleLoginUsecase(idToken);
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
    } catch (e, st) {
      debugPrint('Google sign-in error: $e\n$st');
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}
