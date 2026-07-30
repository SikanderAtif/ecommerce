import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  User? currentUser() {
    return _auth.currentUser;
  }

  Future<void> checkEmailVerified() async {
    // Reload the user data from Firebase servers
    await currentUser()?.reload();
  }

  Future<void> sendVerificationEmail() async {
    try {
      final user = currentUser();
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        debugPrint('Verification Email sent to ${user.email}');
      }
    } catch (e) {
      debugPrint('Error sending verification email: $e');
      rethrow;
    }
  }

  Future<User?> signUpUser(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        debugPrint('The password provided is too weak.');
        return null;
      } else if (e.code == 'email-already-in-use') {
        debugPrint('An account already exists for that email.');
        return null;
      }
      rethrow;
    }
  }

  Future<User?> loginUser(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Error Occured: ${e.code}');
      debugPrint(e.message);
      return null;
    }
  }

  Future<UserCredential?> loginWithGoogle() async {
    try {
      await dotenv.load();
      await _googleSignIn.initialize(
        serverClientId: dotenv.env['GOOGLE_WEB_CLIENT_ID'],
      );

      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      final List<String> scopes = ['email', 'profile'];
      final clientAuth = await googleUser.authorizationClient.authorizeScopes(
        scopes,
      );

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: clientAuth.accessToken,
      );

      return await _auth.signInWithCredential(credential);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        debugPrint('User canceled the Google Sign-In flow.');
        return null;
      }
      debugPrint("Google Sign-In Exception: ${e.code}");
      rethrow;
    } on FirebaseAuthException catch (e) {
      debugPrint("Firebase Google Auth Error: ${e.message}");
      return null;
    } catch (e) {
      debugPrint('Google Sign In Error: $e');
      return null;
    }
  }

  Future<void> delete(String password) async {
    User? user = currentUser();
    if (user == null) return;

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      
      await user.reauthenticateWithCredential(credential);
      await user.delete();
    } catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }
}
