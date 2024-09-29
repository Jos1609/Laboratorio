import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Método para verificar si el usuario está autenticado
  Future<bool> isUserAuthenticated() async {
    User? user = _auth.currentUser;
    return user != null;
  }
}
