import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthService extends GetxService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  
  Stream<User?> get authStateChanges => auth.authStateChanges();

  User? get currentUser => auth.currentUser;

  Future<String?> login(String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') return 'No user found for that email';
      if (e.code == 'wrong-password') return 'Wrong password provided';
      if (e.code == 'invalid-credential') return 'Invalid credentials';
      return e.message ?? 'Authentication failed';
    } catch (e) {
      return 'An unexpected error occurred';
    }
  }

  Future<String?> signup(String email, String password) async {
    try {
      await auth.createUserWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') return 'The password provided is too weak';
      if (e.code == 'email-already-in-use') return 'An account already exists for that email';
      return e.message ?? 'Registration failed';
    } catch (e) {
      return 'An unexpected error occurred';
    }
  }

  Future<String?> resetPassword(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Failed to send reset email';
    } catch (e) {
      return 'An unexpected error occurred';
    }
  }

  Future<void> logout() async {
    await auth.signOut();
  }
}

