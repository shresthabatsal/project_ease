import 'package:project_ease/features/auth/data/models/auth_api_model.dart';
import 'package:project_ease/features/auth/data/models/auth_hive_model.dart';

abstract interface class IAuthLocalDatasource {
  Future<bool> registerUser(AuthHiveModel model);
  Future<AuthHiveModel?> loginUser(String email, String password);
  Future<AuthHiveModel?> getCurrentUser();
  Future<bool> logoutUser();
  Future<bool> isEmailExists(String email);
}

abstract interface class IAuthRemoteDatasource {
  Future<AuthApiModel> registerUser(AuthApiModel user);
  Future<AuthApiModel?> loginUser(String email, String password);
  Future<AuthApiModel?> getuserById(String authId);
}