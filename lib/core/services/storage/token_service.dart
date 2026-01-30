import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/services/storage/user_service_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

final tokenServiceProvider = Provider<TokenService>((ref) {
  return TokenService(prefs: ref.read(sharedPreferencesProvider));
});

class TokenService {
  static const String _tokenKey = 'auth_token';
  final SharedPreferences _prefs;

  TokenService({required SharedPreferences prefs}) : _prefs = prefs;

  // Save Token
  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  // Get Token
  Future<String?> getToken() async {
    return _prefs.getString(_tokenKey);
  }

  // Remove Token
  Future<void> removeToken() async {
    await _prefs.remove(_tokenKey);
  }
}
