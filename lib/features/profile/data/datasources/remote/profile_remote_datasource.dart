import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/api/api_client.dart';
import 'package:project_ease/core/api/api_endpoints.dart';
import 'package:project_ease/features/auth/data/models/auth_api_model.dart';

final profileRemoteDatasourceProvider = Provider<ProfileRemoteDatasource>(
  (ref) => ProfileRemoteDatasource(apiClient: ref.read(apiClientProvider)),
);

class ProfileRemoteDatasource {
  final ApiClient _apiClient;
  ProfileRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  Future<AuthApiModel> getProfile() async {
    final response = await _apiClient.get(ApiEndpoints.getProfile);
    return AuthApiModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<AuthApiModel> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? email,
    String? password,
    String? profilePicturePath,
    bool removeProfilePicture = false,
  }) async {
    final fields = <String, dynamic>{
      if (fullName != null) 'fullName': fullName,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (email != null) 'email': email,
      if (password != null) 'password': password,
      if (removeProfilePicture) 'profilePictureUrl': '',
    };

    if (profilePicturePath != null) {
      final formData = FormData.fromMap({
        ...fields,
        'profilePicture': await MultipartFile.fromFile(profilePicturePath),
      });
      final response = await _apiClient.put(
        ApiEndpoints.updateProfile,
        data: formData,
      );
      return AuthApiModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    }

    // JSON for text-only updates
    final response = await _apiClient.put(
      ApiEndpoints.updateProfile,
      data: fields,
    );
    return AuthApiModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }
}
