import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/muestra.dart';

class MuestraService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('muestras');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Método para obtener la lista de muestras filtradas por el usuario actual
  Future<List<Muestra>> fetchMuestras() async {
    final User? user = _auth.currentUser;
    final String userId = user?.uid ?? '';

    print('User ID: $userId');

    List<Muestra> muestrasList = [];

    if (userId.isEmpty) {
      print('No user authenticated');
      return muestrasList;
    }

    try {
      DatabaseEvent event = await _dbRef.orderByChild('userId').equalTo(userId).once();
      DataSnapshot snapshot = event.snapshot;

      print('Snapshot value: ${snapshot.value}');

      if (snapshot.value != null) {
        Map<dynamic, dynamic> muestrasMap = Map<dynamic, dynamic>.from(snapshot.value as Map);

        muestrasMap.forEach((key, value) {
          Muestra muestra = Muestra.fromMap(Map<String, dynamic>.from(value), key);
          if (muestra.estado == 'dejado') {
            muestrasList.add(muestra);
          }
        });
      } else {
        print('No data found for user');
      }
    } catch (e) {
      print('Error al cargar muestras: $e');
    }

    print('Muestras list length: ${muestrasList.length}');
    return muestrasList;
  }

  // Método para actualizar el estado de una muestra
  Future<void> updateMuestraEstado(String muestraKey, String estado, String dateR) async {
    await _dbRef.child(muestraKey).update({
      'estado': estado,
      'dateR': dateR,
    });
  }

  // Método para obtener un stream en tiempo real de las muestras filtradas por el usuario
  Stream<DatabaseEvent> getMuestrasStream() {
    final User? user = _auth.currentUser;
    final String userId = user?.uid ?? '';
    return _dbRef.orderByChild('userId').equalTo(userId).onValue;
  }
}
