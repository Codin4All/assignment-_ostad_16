
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Stream<User?> authChanges() {
    return _auth.authStateChanges();
  }

  static Future<UserCredential> signUp(
    String email,
    String password,
  ) {
    return _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  static Future<UserCredential> signIn(
    String email,
    String password,
  ) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  static Future<UserCredential> signInWithGoogle() {
    final provider = GoogleAuthProvider();
    provider.addScope('email');

    return _auth.signInWithPopup(provider);
  }

  static Future<void> signOut() {
    return _auth.signOut();
  }

  static Future<void> resetPassword(String email) {
    return _auth.sendPasswordResetEmail(
      email: email.trim(),
    );
  }
}