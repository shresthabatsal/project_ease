import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:project_ease/core/constants/hive_table_constant.dart';
import 'package:project_ease/features/auth/data/models/auth_hive_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:project_ease/features/product/data/models/category_hive_model.dart';
import 'package:project_ease/features/product/data/models/product_hive_model.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

class HiveService {
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
    if (!Hive.isAdapterRegistered(HiveTableConstant.productTypeId)) {
      Hive.registerAdapter(ProductHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstant.categoryTypeId)) {
      Hive.registerAdapter(CategoryHiveModelAdapter());
    }
  }

  // Open Boxes
  Future<void> _openBox() async {
    await Hive.openBox<AuthHiveModel>(HiveTableConstant.userTable);
    await Hive.openBox<CategoryHiveModel>(HiveTableConstant.categoriesTable);
  }

  // Close all boxes
  Future<void> close() async {
    await Hive.close();
  }

  // ==================== Auth Queries ====================

  Box<AuthHiveModel> get _authBox =>
      Hive.box<AuthHiveModel>(HiveTableConstant.userTable);

  Future<AuthHiveModel> registerUser(AuthHiveModel user) async {
    await _authBox.put(user.authId, user);
    return user;
  }

  Future<AuthHiveModel?> loginUser(String email, String password) async {
    final users = _authBox.values.where(
      (user) => user.email == email && user.password == password,
    );
    if (users.isNotEmpty) {
      return users.first;
    }
    return null;
  }

  AuthHiveModel? getCurrentUser() {
    if (_authBox.isEmpty) return null;
    return _authBox.values.first;
  }

  Future<void> logoutUser() async {}

  bool isEmailExists(String email) {
    final users = _authBox.values.where((user) => user.email == email);
    return users.isNotEmpty;
  }
}
