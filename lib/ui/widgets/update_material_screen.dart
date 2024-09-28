import 'package:flutter/material.dart';
import 'package:laboratorio/data/repositories/material_repository.dart';

class UpdateMaterialCard extends StatelessWidget {
  final Map<String, dynamic> material; // Define el mapa como String y dinámico

  const UpdateMaterialCard({super.key, required this.material});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController =
        TextEditingController(text: material['name']);
    final TextEditingController stockController =
        TextEditingController(text: material['stock'].toString());
    final TextEditingController unitController =
        TextEditingController(text: material['unit']);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: 250, // Ajusta el ancho de la tarjeta
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration:
                    const InputDecoration(labelText: 'Nombre del material'),
              ),
              TextField(
                controller: stockController,
                decoration: const InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: unitController,
                decoration:
                    const InputDecoration(labelText: 'Unidad de medida'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final updatedData = {
                    'id': material['id'], // Incluye el ID aquí
                    'name': nameController.text,
                    'stock': int.tryParse(stockController.text) ?? 0,
                    'unit': unitController.text,
                  };

                  // Validación de campos no vacíos
                  if (updatedData['name'].isNotEmpty && updatedData['unit'].isNotEmpty) {
                    if (material['id'] != null) {
                      try {
                        print('Actualizando material con ID: ${material['id']}');
                        await MaterialRepository().updateMaterial(material['id'], updatedData);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Material actualizado correctamente.')),
                        );
                        Navigator.pop(context);
                      } catch (e) {
                        print('Error al actualizar el material: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Error al actualizar el material.')),
                        );
                      }
                    } else {
                      print('El ID del material es nulo.');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Error: el ID del material es nulo.')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Por favor completa todos los campos.')),
                    );
                  }
                },
                child: const Text('Guardar cambios'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
