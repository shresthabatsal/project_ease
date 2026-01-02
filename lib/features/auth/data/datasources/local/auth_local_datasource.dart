import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/services/hive/hive_service.dart';
import 'package:project_ease/features/auth/data/datasources/auth_datasource.dart';
import 'package:project_ease/features/auth/data/models/auth_hive_model.dart';

// Provider
final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return AuthLocalDatasource(hiveService: hiveService);
});

class AuthLocalDatasource implements IAuthDatasource {
  final HiveService _hiveService;
  AuthLocalDatasource({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
@override
Future<AuthHiveModel> getCurrentUser() {
  try {
    final user = _hiveService.getCurrentUser();
    return Future.value(user);
  } catch (e) {
    throw Future.value(null);
  }
}

  @override
  Future<bool> isEmailExists(String email) {
    try {
      final exists = _hiveService.isEmailExists(email);
      return Future.value(exists);
    } catch (e) {
      throw Future.value(false);
    }
  }

  @override
  Future<AuthHiveModel?> loginUser(String email, String password) async {
    try {
      final user = await _hiveService.loginUser(email, password);
      return Future.value(user);
    } catch (e) {
      throw Future.value(null);
    }
  }

  @override
  Future<bool> logoutUser() {
    try {
      _hiveService.logoutUser();
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  }

  @override
  Future<bool> registerUser(AuthHiveModel model) async {
    try {
      await _hiveService.registerUser(model);
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  }
}
