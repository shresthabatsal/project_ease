import 'package:hive/hive.dart';
import 'package:project_ease/core/constants/hive_table_constant.dart';
import 'package:project_ease/features/auth/data/models/auth_hive_model.dart';

import 'package:path_provider/path_provider.dart';

class AuthHiveService {
  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/${HiveTableConstant.dbName}";
    Hive.init(path);
    _registerAdapters();
    await _openBox();
  }

  // Register Adapters
  void _registerAdapters() {
    if (!Hive.isAdapterRegistered(HiveTableConstant.userTypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
  }

  // Open Boxes
  Future<void> _openBox() async {
    await Hive.openBox<AuthHiveModel>(HiveTableConstant.userTable);
  }

  // Close all boxes
  Future<void> close() async {
    await Hive.close();
  }

  // ==================== Auth Queries ====================

  Box<AuthHiveModel> get _authBox =>
      Hive.box<AuthHiveModel>(HiveTableConstant.userTable);

  // Register
  Future<AuthHiveModel> registerUser(AuthHiveModel user) async {
    await _authBox.put(user.authId, user);
    return user;
  }

  // Login
  AuthHiveModel? loginUser(String email, String password) {
    final users = _authBox.values.where(
      (user) => user.email == email && user.password == password,
    );
    if (users.isNotEmpty) {
      return users.first;
    }
    return null;
  }

  // Get Current User
  AuthHiveModel? getCurrentUser(String authId) {
    return _authBox.get(authId);
  }

  // Logout
  Future<void> logoutUser(String authId) async {
    await _authBox.delete(authId);
  }

  // Is Email Exists
  bool isEmailExists(String email) {
    final users = _authBox.values.where((user) => user.email == email);
    return users.isNotEmpty;
  }
}