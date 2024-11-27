import 'package:firebase_database/firebase_database.dart';

Future<String> getUserType(String userId) async {
  // Verificar en la colección "docente"
  final docenteSnapshot = await FirebaseDatabase.instance.ref().child('docente').child(userId).get();
  if (docenteSnapshot.exists) {
    return 'docente';
  }

  // Verificar en la colección "admin"
  final adminSnapshot = await FirebaseDatabase.instance.ref().child('admin').child(userId).get();
  if (adminSnapshot.exists) {
    return 'admin';
  }

  return 'unknown';
}