import 'package:laboratorio/data/models/material.dart';

class Muestra {
  final String title;
  final String course;
  final String? date;
  final String? dateR;
  final List<LabMaterial> muestras; 
  final String estado;
  final String userId;

  Muestra({
    required this.title,
    required this.course,
    this.date,
    this.dateR,
    required this.muestras,
    required this.userId,
    required this.estado,
  });

 

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'course': course,
      'date': date,
      'dateR': dateR,
      'muestras': muestras.map((m) => m.toMap()).toList(), // Asegúrate de definir toMap en LabMaterial
      'userId': userId,
      'estado': estado,
    };
  }

  static Muestra fromMap(Map<String, dynamic> map, String key) {
    return Muestra(
      title: map['title'],
      course: map['course'],
      date: map['date'],
      dateR: map['dateR'],
      muestras: (map['muestras'] as List).map((m) => LabMaterial.fromMap(m)).toList(),
      userId: map['userId'],
      estado: map['estado'],
    );
  }
  
  
}
