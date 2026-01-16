import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/api/api_client.dart';
import 'package:project_ease/core/api/api_endpoints.dart';
import 'package:project_ease/core/services/storage/user_service_session.dart';
import 'package:project_ease/features/auth/data/datasources/auth_datasource.dart';
import 'package:project_ease/features/auth/data/models/auth_api_model.dart';

final authRemoteDatasourceProvider = Provider<IAuthRemoteDatasource>((ref) {
  return AuthRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider),
  );
});

class AuthRemoteDatasource implements IAuthRemoteDatasource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;

  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
  }) : _apiClient = apiClient,
       _userSessionService = userSessionService;

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

    await _userSessionService.saveUserSession(
      userId: user.id!,
      email: user.email,
      phoneNumber: user.phoneNumber,
      fullName: user.fullName,
    );
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
}
