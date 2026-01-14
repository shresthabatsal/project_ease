import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// SharedPreferences provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences not initialized.');
});

// User session provider
final userSessionServiceProvider = Provider<UserSessionService>((ref) {
  return UserSessionService(
    prefs: ref.read(sharedPreferencesProvider),
  );
});

class UserSessionService {
  final SharedPreferences _prefs;

  UserSessionService({required SharedPreferences prefs}) : _prefs = prefs;

  // Keys
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserFullName = 'user_full_name';
  static const String _keyUserPhoneNumber = 'user_phone_number';
  static const String _keyAuthToken = 'auth_token';

  // Save User Session
  Future<void> saveUserSession({
    required String userId,
    required String email,
    required String fullName,
    String? phoneNumber,
    required String authToken,
  }) async {
    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setString(_keyUserId, userId);
    await _prefs.setString(_keyUserEmail, email);
    await _prefs.setString(_keyUserFullName, fullName);
    await _prefs.setString(_keyAuthToken, authToken);

    if (phoneNumber != null) {
      await _prefs.setString(_keyUserPhoneNumber, phoneNumber);
    }
  }

  // Clear Session
  Future<void> clearUserSession() async {
    await _prefs.remove(_keyIsLoggedIn);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyUserEmail);
    await _prefs.remove(_keyUserFullName);
    await _prefs.remove(_keyUserPhoneNumber);
    await _prefs.remove(_keyAuthToken);
  }

  bool isLoggedIn() {
    return _prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  String? getUserId() {
    return _prefs.getString(_keyUserId);
  }

  String? getUserEmail() {
    return _prefs.getString(_keyUserEmail);
  }

  String? getUserFullName() {
    return _prefs.getString(_keyUserFullName);
  }

  String? getUserPhoneNumber() {
    return _prefs.getString(_keyUserPhoneNumber);
  }

  String? getAuthToken() {
    return _prefs.getString(_keyAuthToken);
  }
}
