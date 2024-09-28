import '../../services/firebase_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuthService _authService;

  AuthRepository(this._authService);

  Future<User?> signIn(String email, String password) {
    return _authService.signInWithEmailAndPassword(email, password);
  }

  Future<void> signOut() {
    return _authService.signOut();
  }

  Future<User?> register(String email, String password) {
    return _authService.registerWithEmailAndPassword(email, password);
  }
  // Método para enviar el enlace de recuperación de contraseña
  Future<void> sendPasswordResetEmail(String email) async {
    await _authService.sendPasswordResetEmail(email);
  }
}
