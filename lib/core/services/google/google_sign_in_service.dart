import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

final googleSignInServiceProvider = Provider<GoogleSignInService>((ref) {
  return GoogleSignInService();
});

class GoogleSignInService {
  final _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  Future<String?> getIdToken() async {
    try {
      await _googleSignIn.signOut();

      final account = await _googleSignIn.signIn();
      if (account == null) return null;

      final auth = await account.authentication;
      return auth.idToken;
    } catch (e) {
      return null;
    }
  }
}
