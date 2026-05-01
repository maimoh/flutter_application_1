import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class GoogleSignInService {
  static final _auth = FirebaseAuth.instance;
  static final _googleSignIn = GoogleSignIn();

  /// Returns the signed-in [User] or null if the user cancelled.
  /// Throws [FirebaseAuthException] or generic [Exception] on failure.
  static Future<User?> signIn() async {
    if (kIsWeb) {
      // ── Web: use signInWithPopup ────────────────────────────────
      final provider = GoogleAuthProvider();
      provider.addScope('email');
      final result = await _auth.signInWithPopup(provider);
      return result.user;
    } else {
      // ── Mobile (Android / iOS): use google_sign_in package ─────
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // user cancelled

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);
      return result.user;
    }
  }
}