import 'dart:io';
import 'package:project_ease/features/auth/data/models/auth_api_model.dart';

abstract interface class IProfileRemoteDataSource {
  Future<AuthApiModel> getProfile();
  Future<AuthApiModel> updateProfile(AuthApiModel profile);
  Future<String> uploadProfilePicture(File image);
  Future<bool> deleteAccount();
}
