import 'package:project_ease/features/auth/data/models/auth_hive_model.dart';

abstract interface class IAuthDatasource {
  Future<bool> registerUser(AuthHiveModel model);
  Future<AuthHiveModel> loginUser(String email, String password);
  Future<AuthHiveModel> getCurrentUser();
  Future<bool> logoutUser();
  Future<bool> isEmailExists(String email);
}