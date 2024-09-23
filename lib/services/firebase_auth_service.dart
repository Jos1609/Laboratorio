import 'package:firebase_auth/firebase_auth.dart';
import '../core/utils/custom_exceptions.dart';

class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw CustomException(e.message ?? 'Error en la autenticación');
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw CustomException(e.message ?? 'Error en la autenticación');
    }
  }
  // Método para enviar el enlace de recuperación de contraseña
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }
}
