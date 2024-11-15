

import 'package:firebase_database/firebase_database.dart';
import 'package:laboratorio/data/models/incidencia_model.dart';
class IncidenciaRepository {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('incidencias');

  Stream<DatabaseEvent> getIncidenciasStream() {
    return _dbRef.onValue;
  }

  Future<void> addIncidencia(Incidencia incidencia) {
    return _dbRef.push().set(incidencia.toMap());
  }

  Future<void> updateIncidenciaStatus(String key, String estado) {
    return _dbRef.child(key).update({'estado': estado});
  }
}