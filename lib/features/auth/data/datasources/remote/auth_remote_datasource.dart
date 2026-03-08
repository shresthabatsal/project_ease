import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/api/api_client.dart';
import 'package:project_ease/core/api/api_endpoints.dart';
import 'package:project_ease/core/services/storage/token_service.dart';
import 'package:project_ease/core/services/storage/user_service_session.dart';
import 'package:project_ease/features/auth/data/datasources/auth_datasource.dart';
import 'package:project_ease/features/auth/data/models/auth_api_model.dart';

final authRemoteDatasourceProvider = Provider<IAuthRemoteDatasource>((ref) {
  return AuthRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class AuthRemoteDatasource implements IAuthRemoteDatasource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;
  final TokenService _tokenService;

  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _userSessionService = userSessionService,
       _tokenService = tokenService;

  @override
  Future<AuthApiModel?> getuserById(String authId) {
    // TODO: implement getuserById
    throw UnimplementedError();
  }

  @override
  Future<AuthApiModel?> loginUser(String email, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );

    if (response.data["success"] == true) {
      final data = response.data["data"] as Map<String, dynamic>;
      final user = AuthApiModel.fromJson(data);

      // Save User Session
      await _userSessionService.saveUserSession(
        userId: user.id!,
        email: user.email,
        phoneNumber: user.phoneNumber,
        fullName: user.fullName,
      );

      // Save Token
      final token = response.data["token"];
      await _tokenService.saveToken(token);

      return user;
    }
    return null;
  }

  @override
  Future<AuthApiModel> registerUser(AuthApiModel user) async {
    final response = await _apiClient.post(
      ApiEndpoints.register,
      data: user.toJson(),
    );

    if (response.data["success"] == true) {
      final data = response.data["data"] as Map<String, dynamic>;
      final registeredUser = AuthApiModel.fromJson(data);
      return registeredUser;
    }

    return user;
  }

  @override
  Future<bool> sendPasswordResetEmail(String email) async {
    final response = await _apiClient.post(
      ApiEndpoints.requestPasswordReset,
      data: {'email': email},
    );
    return response.data["success"] == true;
  }

  Future<void> _saveSession(AuthApiModel user, String token) async {
    await _userSessionService.saveUserSession(
      userId: user.id!,
      email: user.email,
      phoneNumber: user.phoneNumber,
      fullName: user.fullName,
    );
    await _tokenService.saveToken(token);
  }

  @override
  Future<AuthApiModel?> googleLogin(String idToken) async {
    final response = await _apiClient.post(
      ApiEndpoints.googleAuth,
      data: {'token': idToken},
    );

    if (response.data['success'] == true) {
      final user = AuthApiModel.fromJson(
          response.data['data'] as Map<String, dynamic>);
      await _saveSession(user, response.data['token']);
      return user;
    }
    return null;
  }
}
