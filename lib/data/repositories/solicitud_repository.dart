import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:laboratorio/data/models/solicitud_model.dart';
import 'package:laboratorio/data/models/muestra_model.dart';

class SolicitudRepository {
  final DatabaseReference _solicitudesRef =
      FirebaseDatabase.instance.ref().child('solicitudes');
  final DatabaseReference _muestraRef =
      FirebaseDatabase.instance.ref().child('muestras');

  Future<void> addSolicitud(Solicitud solicitud) async {
    await _solicitudesRef.push().set(solicitud.toMap());
  }

  Future<void> addMuestra(Muestra muestra) async {
    await _muestraRef.push().set(muestra.toMap());
  }

  Future<void> createSolicitud(Solicitud solicitud) async {
    try {
      final solicitudJson = {
        'title': solicitud.title,
        'course': solicitud.course,
        'studentCount': solicitud.studentCount,
        'turn': solicitud.turn,
        'date': solicitud.date,
        'startTime': solicitud.startTime,
        'endTime': solicitud.endTime,
        'materials': solicitud.materials
            .map((material) => {
                  'name': material.name,
                  'quantity': material.quantity,
                  'unit': material.unit
                })
            .toList(),
        'userId': solicitud.userId,
      };

      await _solicitudesRef.push().set(solicitudJson);
    } catch (e) {
      // Manejo de errores
      print('Error al crear solicitud: $e');
    }
  }

  Future<void> createMuestra(Muestra muestra) async {
    try {
      final muestraJson = {
        'title': muestra.title,
        'course': muestra.course,
        'date': muestra.date,
        'dateR': muestra.dateR,
        'muestras': muestra.muestras
            .map((muestra) => {
                  'name': muestra.name,
                  'quantity': muestra.quantity,
                  'unit': muestra.unit
                })
            .toList(),
        'userId': muestra.userId,
        'estado': muestra.estado,
      };

      await _muestraRef.push().set(muestraJson);
    } catch (e) {
      // Manejo de errores
      print('Error al crear muestra: $e');
    }
  }

  Future<List<Solicitud>> getSolicitudes() async {
    final DatabaseEvent event = await _solicitudesRef.once();
    final List<Solicitud> solicitudes = [];

    if (event.snapshot.exists) {
      final Map<String, dynamic> data = Map<String, dynamic>.from(
          event.snapshot.value as Map<dynamic, dynamic>);

      data.forEach((key, value) {
        final solicitud =
            Solicitud.fromMap(Map<String, dynamic>.from(value), key);
        solicitudes.add(solicitud);
      });
    }
    return solicitudes;
  }

  Future<List<Muestra>> getMuestras() async {
    final DatabaseEvent event = await _muestraRef.once();
    final List<Muestra> muestrass = [];

    if (event.snapshot.exists) {
      final Map<String, dynamic> data = Map<String, dynamic>.from(
          event.snapshot.value as Map<dynamic, dynamic>);

      data.forEach((key, value) {
        final muest = Muestra.fromMap(Map<String, dynamic>.from(value), key);
        muestrass.add(muest);
      });
    }

    return muestrass;
  }

Future<List<Solicitud>> getSolicitudesByDate(DateTime? date) async {
  if (date == null) return [];
  final formattedDate = DateFormat('d/M/yyyy').format(date);
  final snapshot = await FirebaseDatabase.instance
      .ref()
      .child('solicitudes')
      .orderByChild('date')
      .equalTo(formattedDate)
      .get();

  if (!snapshot.exists) {

    return [];
  }
  final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
  
  return data.entries.map((entry) {
    try {
      final solicitudData = Map<String, dynamic>.from(entry.value as Map);
      return Solicitud(
        date: solicitudData['date'], 
        startTime: solicitudData['startTime'],
        endTime: solicitudData['endTime'], 
        title: '', course: '', studentCount: '', turn: '', materials: [], userId: '',
       
      );
    } catch (e) {
    
      return null;
    }
  }).where((solicitud) => solicitud != null).cast<Solicitud>().toList();
}

}
