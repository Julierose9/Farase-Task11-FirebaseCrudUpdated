import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GoogleSignIn? _googleSignIn = kIsWeb ? null : GoogleSignIn();

 
  Future<User?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        UserCredential userCredential = await _auth.signInWithPopup(
          googleProvider,
        );
        return userCredential.user;
      } else {
        final GoogleSignInAccount? googleUser = await _googleSignIn?.signIn();
        if (googleUser == null) return null;

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        return (await _auth.signInWithCredential(credential)).user;
      }
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    }
  }

  // -----------------------------
  // REGISTER Email & Password
  // -----------------------------
  Future<User?> registerWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Register Error: $e");
      return null;
    }
  }

 
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Login Error: $e");
      return null;
    }
  }

  
  Future<bool> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      print("Password Reset Error: $e");
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        await _googleSignIn?.signOut();
      }
      await _auth.signOut();
    } catch (e) {
      print("Sign Out Error: $e");
    }
  }

  Stream<User?> get userStream => _auth.authStateChanges();
}
