// Ubicación del archivo: lib/data/repositories/material_repository.dart
import 'package:firebase_database/firebase_database.dart';

class MaterialRepository {
  final DatabaseReference _ref =
      FirebaseDatabase.instance.ref().child('materiales');

  Future<void> addMaterial(String name, int stock, String unit) async {
    // Usar push() aquí para agregar un nuevo material
    try {
      await _ref.push().set({
        'name': name,
        'stock': stock,
        'unit': unit,
      });
      print('Material agregado correctamente: $name');
    } catch (e) {
      print('Error al agregar material: $e');
      throw e; // Vuelve a lanzar el error para que se capture en el llamador
    }
  }

  Future<void> updateMaterial(String id, Map<String, dynamic> newData) async {
    await _ref.child(id).update(newData);
  }

  Future<void> deleteMaterial(String id) async {
    await _ref.child(id).remove();
  }
}
