import 'package:laboratorio/data/models/material.dart';

class Solicitud {
  final String title;
  final String course;
  final String studentCount;
  final String turn;
  final String? date;
  final String? startTime;
  final String? endTime;
  final List<LabMaterial> materials; // Cambiado a LabMaterial
  final String userId;

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
      'materials': materials.map((m) => m.toMap()).toList(), // Asegúrate de definir toMap en LabMaterial
      'userId': userId,
    };
  }

  static Solicitud fromMap(Map<String, dynamic> map, String key) {
    return Solicitud(
      title: map['title'],
      course: map['course'],
      studentCount: map['studentCount'],
      turn: map['turn'],
      date: map['date'],
      startTime: map['startTime'],
      endTime: map['endTime'],
      materials: (map['materials'] as List).map((m) => LabMaterial.fromMap(m)).toList(),
      userId: map['userId'],
    );
  }
}
