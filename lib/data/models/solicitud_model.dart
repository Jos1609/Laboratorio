import 'package:laboratorio/data/models/material.dart';

class Solicitud {
  final String title;
  final String course;
  final String studentCount;
  final String turn;
  final String? date;
  final String? startTime;
  final String? endTime;
  final List<LabMaterial> materials;
  final String userId;
  String? docente;
  String? laboratorio; // Nuevo atributo opcional

  Solicitud({
    required this.title,
    required this.course,
    required this.studentCount,
    required this.turn,
    this.date,
    this.startTime,
    this.endTime,
    required this.materials,
    required this.userId,
    this.docente,
    this.laboratorio, // Nuevo parámetro opcional
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'course': course,
      'studentCount': studentCount,
      'turn': turn,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'materials': materials.map((m) => m.toMap()).toList(),
      'userId': userId,
      'docente': docente,
      'laboratorio': laboratorio, // Agregar al mapa
    };
  }

  static Solicitud fromMap(Map<String, dynamic> map, String key) {
    return Solicitud(
      title: map['title'] ?? '',
      course: map['course'] ?? '',
      studentCount: map['studentCount']?.toString() ?? '',
      turn: map['turn'] ?? '',
      date: map['date'],
      startTime: map['startTime'],
      endTime: map['endTime'],
      materials: (map['materials'] as List?)
              ?.map((m) => LabMaterial.fromMap(m as Map<String, dynamic>))
              .toList() ??
          [],
      userId: map['userId'] ?? '',
      docente: map['docente'],
      laboratorio: map['laboratorio'], // Obtener del mapa
    );
  }

  factory Solicitud.fromJson(Map<String, dynamic> json) {
    return Solicitud(
      title: json['title'] as String? ?? '',
      course: json['course'] as String? ?? '',
      studentCount: json['studentCount']?.toString() ?? '',
      turn: json['turn'] as String? ?? '',
      date: json['date'] as String?,
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      materials: (json['materials'] as List<dynamic>?)
              ?.map((m) => LabMaterial.fromMap(m as Map<String, dynamic>))
              .toList() ??
          [],
      userId: json['userId'] as String? ?? '',
      docente: json['docente'] as String? ?? '',
      laboratorio: json['laboratorio'] as String?, 
    );
  }
}