import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/api/api_client.dart';
import 'package:project_ease/core/api/api_endpoints.dart';
import 'package:project_ease/core/services/storage/token_service.dart';
import 'package:project_ease/features/auth/data/models/auth_api_model.dart';
import 'package:project_ease/features/profile/data/datasources/profile_datasource.dart';

final profileRemoteDataSourceProvider = Provider<IProfileRemoteDataSource>((
  ref,
) {
  return ProfileRemoteDataSource(
    apiClient: ref.read(apiClientProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class ProfileRemoteDataSource implements IProfileRemoteDataSource {
  final ApiClient _apiClient;
  final TokenService _tokenService;

  ProfileRemoteDataSource({
    required ApiClient apiClient,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _tokenService = tokenService;

  @override
  Future<AuthApiModel> getProfile() async {
    final token = await _tokenService.getToken();
    final response = await _apiClient.get(
      ApiEndpoints.getProfile,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    final data = response.data['data'] ?? response.data;
    return AuthApiModel.fromJson(data);
  }

  @override
Future<AuthApiModel> updateProfile(AuthApiModel profile) async {
  final token = await _tokenService.getToken();

  final formData = FormData.fromMap({
    'fullName': profile.fullName,
    'email': profile.email,
    if (profile.phoneNumber != null && profile.phoneNumber!.isNotEmpty)
      'phoneNumber': profile.phoneNumber,
    // 'password': profile.password ?? '',
    if (profile.profilePicture != null && profile.profilePicture!.isNotEmpty)
      'profilePictureUrl': profile.profilePicture,
  });

  final response = await _apiClient.put(
    ApiEndpoints.updateProfile,
    data: formData,
    options: Options(
      headers: {
        'Authorization': 'Bearer $token',
      },
    ),
  );

  final data = response.data['data'] ?? response.data;
  return AuthApiModel.fromJson(data);
}

  @override
  Future<String> uploadProfilePicture(File image) async {
    final fileName = image.path.split('/').last;
    final formData = FormData.fromMap({
      'profilePicture': await MultipartFile.fromFile(
        image.path,
        filename: fileName,
      ),
    });

    final token = await _tokenService.getToken();
    final response = await _apiClient.uploadFile(
      ApiEndpoints.uploadProfilePicture,
      formData: formData,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    final Map<String, dynamic> responseData = response.data;

    if (responseData['success'] != true) {
      throw Exception(
        'Upload failed: ${responseData['message'] ?? 'Unknown error'}',
      );
    }

    return response.data['data'];
  }

  @override
  Future<bool> deleteAccount() async {
    final token = await _tokenService.getToken();
    await _apiClient.delete(
      ApiEndpoints.deleteAccount,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return true;
  }
}
