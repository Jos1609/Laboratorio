import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:laboratorio/data/models/user.dart';

class UsuarioService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  Future<void> registrarUsuario(Usuario usuario) async {
    try {
      // Crear usuario en Firebase Auth
      String password = usuario.apellidos.substring(0, 2) + '2024';
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: usuario.correo,
        password: password,
      );
      
      String uid = userCredential.user!.uid;

      // Definir nodo (docente o admin)
      String nodo = usuario.tipo == 'docente' ? 'docente' : 'admin';
      
      // Guardar datos del usuario en Firebase Realtime Database
      await _dbRef.child(nodo).child(uid).set(usuario.toMap());
      
    } catch (e) {
      throw Exception('Error al registrar usuario: $e');
    }
  }
}
