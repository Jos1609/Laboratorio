import 'package:firebase_database/firebase_database.dart';
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
  

  Future<void> signIn(
      String email, String password, BuildContext context) async {
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
        // Verifica el tipo de usuario en Firebase Realtime Database
        DatabaseReference dbRef = FirebaseDatabase.instance.ref();
        DataSnapshot adminSnapshot =
            await dbRef.child('admin').child(user.uid).get();
        DataSnapshot docenteSnapshot =
            await dbRef.child('docente').child(user.uid).get();

        if (adminSnapshot.exists) {
          // Si el usuario está en el nodo 'admin'
          Navigator.pushReplacementNamed(context, '/home-admin');
        } else if (docenteSnapshot.exists) {
          // Si el usuario está en el nodo 'docente'
          Navigator.pushReplacementNamed(context, '/home-docente');
        } else {
          // Manejo si no se encuentra el usuario en ninguno de los nodos
          Navigator.pushReplacementNamed(context, '/super');
        }
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
  // Método para actualizar la contraseña
  
  Future<void> updatePassword(String newPassword) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    try {
      await user.updatePassword(newPassword);
      // Contraseña actualizada exitosamente
    } catch (e) {
      // Manejar errores, como la expiración de las credenciales o falta de reautenticación
      print('Error al actualizar la contraseña: $e');
    }
  } else {
    print('No hay usuario autenticado.');
  }
}
}
