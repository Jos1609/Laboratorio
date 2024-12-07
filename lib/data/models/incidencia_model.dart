// lib/data/models/incidencia_model.dart

class Incidencia {
  String? id;
  final String nombrePractica;
  final String lugar;
  final String observador;
  final String curso;
  final String incidente;
  final String tratamiento;
  final String derivacion;
  final String compromiso;
  final String estado;
  final String fecha;

  Incidencia({
    this.id,
    required this.nombrePractica,
    required this.lugar,
    required this.observador,
    required this.curso,
    required this.incidente,
    required this.tratamiento,
    required this.derivacion,
    required this.compromiso,
    required this.estado,
    required this.fecha,
  });

  Map<String, dynamic> toMap() {
    return {
      'nombrePractica': nombrePractica,
      'lugar': lugar,
      'observador': observador,
      'curso': curso,
      'incidente': incidente,
      'tratamiento': tratamiento,
      'derivacion': derivacion,
      'compromiso': compromiso,
      'estado': estado,
      'fecha': fecha,
    };
  }

  factory Incidencia.fromMap(Map<dynamic, dynamic> data, [String? id]) {
    return Incidencia(
      id: id,
      nombrePractica: data['nombrePractica']?.toString() ?? '',
      lugar: data['lugar']?.toString() ?? '',
      observador: data['observador']?.toString() ?? '',
      curso: data['curso']?.toString() ?? '',
      incidente: data['incidente']?.toString() ?? '',
      tratamiento: data['tratamiento']?.toString() ?? '',
      derivacion: data['derivacion']?.toString() ?? '',
      compromiso: data['compromiso']?.toString() ?? '',
      estado: data['estado']?.toString() ?? 'Pendiente',
      fecha: data['fecha']?.toString() ?? '',
    );
  }
}