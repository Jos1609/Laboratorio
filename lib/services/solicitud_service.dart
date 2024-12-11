import 'package:firebase_database/firebase_database.dart';
import 'package:laboratorio/data/models/solicitud_model.dart';
import 'package:flutter/material.dart';

class SolicitudService {
  final DatabaseReference _materialsRef =
      FirebaseDatabase.instance.ref().child('materiales');
  final DatabaseReference _solicitudesRef =
      FirebaseDatabase.instance.ref().child('solicitudes');

 

  Future<void> saveSolicitud(Solicitud solicitud) async {
    try {
      await _solicitudesRef.push().set(solicitud.toMap());
    } catch (e) {
      throw Exception("Error al guardar la solicitud: $e");
    }
  }

  Future<Map<String, dynamic>> loadMaterials() async {
    final DataSnapshot snapshot = await _materialsRef.get();
    if (snapshot.exists) {
      Map<dynamic, dynamic> materialsMap =
          snapshot.value as Map<dynamic, dynamic>;
      return materialsMap.map((key, value) => MapEntry(key as String, {
            'name': value['name'] as String? ?? '',
            'quantity': value['stock'] as int? ?? 0,
            'unit': value['unit'] as String? ?? '',
          }));
    }
    return {};
  }

  TimeOfDay _parseTimeOfDay(String timeStr) {
    final parts = timeStr.split(RegExp(r'[:\s]'));

    if (parts.length < 2) {
      throw FormatException('Formato de hora inválido: $timeStr');
    }

    final hour = int.tryParse(parts[0]) ??
        (throw FormatException('Hora inválida: ${parts[0]}'));
    final minute = int.tryParse(parts[1]) ??
        (throw FormatException('Minutos inválidos: ${parts[1]}'));
    final period = parts.length > 2 ? parts[2].toUpperCase() : '';

    if (hour == 0 || hour > 12) {
      throw FormatException('Hora fuera de rango: $hour');
    }

    if (period == 'PM' && hour != 12) {
      return TimeOfDay(hour: hour + 12, minute: minute);
    } else if (period == 'AM' && hour == 12) {
      return TimeOfDay(hour: 0, minute: minute);
    } else {
      return TimeOfDay(hour: hour, minute: minute);
    }
  }
}
