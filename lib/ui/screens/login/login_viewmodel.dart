import 'package:flutter/material.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/utils/custom_exceptions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/utils/validators.dart'; 
import '../../../ui/widgets/auto_dismiss_alert.dart';

class LoginViewModel extends ChangeNotifier {
  AuthRepository _authRepository;
  bool _isLoading = false;

  LoginViewModel(this._authRepository);

  // Método para actualizar el AuthRepository si se cambia
  void updateRepository(AuthRepository authRepository) {
    _authRepository = authRepository;
  }

  bool get isLoading => _isLoading;

  Future<void> signIn(String email, String password, BuildContext context) async {
    // Validaciones antes de intentar iniciar sesión
    final emailError = Validators.validateEmail(email);
    final passwordError = Validators.validatePassword(password);

    if (emailError != null || passwordError != null) {
      // Si hay errores de validación, mostrar el primer mensaje con AutoDismissAlert
      showAutoDismissAlert(context, emailError ?? passwordError!, Colors.red);
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      User? user = await _authRepository.signIn(email, password);
      if (user != null) {
        // Manejar el inicio de sesión exitoso (navegación o mensaje)
        Navigator.pushReplacementNamed(
          context, 
          '/home-admin'
          );
      }
    } on CustomException catch (e) {
      // Manejar errores específicos de autenticación
      debugPrint(e.message);
      showAutoDismissAlert(context, e.message, Colors.red);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Método para cerrar sesión
  Future<void> signOut(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authRepository.signOut();
      // Redirigir al usuario a la pantalla de login después del cierre de sesión
      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      debugPrint('Error cerrando sesión: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
