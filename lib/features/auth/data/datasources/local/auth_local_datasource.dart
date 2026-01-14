import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/services/hive/hive_service.dart';
import 'package:project_ease/core/services/hive/storage/user_service_session.dart';
import 'package:project_ease/features/auth/data/datasources/auth_datasource.dart';
import 'package:project_ease/features/auth/data/models/auth_hive_model.dart';

// Provider
final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
  final hiveService = ref.read(hiveServiceProvider);
  final userSessionService = ref.read(userSessionServiceProvider);
  return AuthLocalDatasource(
    hiveService: hiveService,
    userSessionService: userSessionService,
  );
});

class AuthLocalDatasource implements IAuthLocalDatasource {
  final HiveService _hiveService;
  final UserSessionService _userSessionService;
  AuthLocalDatasource({
    required HiveService hiveService,
    required UserSessionService userSessionService,
  }) : _hiveService = hiveService,
       _userSessionService = userSessionService;

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
      if (user != null){
        await _userSessionService.saveUserSession(
          userId: user.authId!,
          email: user.email,
          fullName: user.fullName,
          phoneNumber: user.phoneNumber
        );
      }
      return user;
    } catch (e) {
      throw Future.value(null);
    }
  }

  @override
  Future<bool> logoutUser() async {
    try {
      _hiveService.logoutUser();
      await _userSessionService.clearUserSession();
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
