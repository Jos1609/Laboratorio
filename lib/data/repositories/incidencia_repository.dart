import 'package:firebase_database/firebase_database.dart';
import '../models/incidencia_model.dart';

class IncidenciaRepository {
  final DatabaseReference _database = FirebaseDatabase.instance.ref().child('incidencias');

  Stream<DatabaseEvent> getIncidenciasStream() {
    return _database.onValue;
  }

  Future<void> addIncidencia(Incidencia incidencia) async {
    await _database.push().set(incidencia.toMap());
  }

  Future<void> updateIncidenciaStatus(String id, String status) async {
    await _database.child(id).update({'estado': status});
  }
}