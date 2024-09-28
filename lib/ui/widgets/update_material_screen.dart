import 'package:flutter/material.dart';
import 'package:laboratorio/data/repositories/material_repository.dart';
import 'package:laboratorio/ui/widgets/custom_snackbar.dart';

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
                  if (updatedData['name'].isNotEmpty &&
                      updatedData['unit'].isNotEmpty) {
                    if (material['id'] != null) {
                      try {
                        print(
                            'Actualizando material con ID: ${material['id']}');
                        await MaterialRepository()
                            .updateMaterial(material['id'], updatedData);
                        CustomSnackbar.show(
                            context,
                            'Material actualizado correctamente.',
                            Colors.green,
                            Icons.check_circle);
                        Navigator.pop(context);
                      } catch (e) {
                        CustomSnackbar.show(
                            context,
                            'Error al actualizar el material: $e',
                            Colors.red,
                            Icons.error);
                      }
                    } else {
                      print('El ID del material es nulo.');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Error: el ID del material es nulo.')),
                      );
                    }
                  } else {
                    CustomSnackbar.show(
                        context,
                        'Completa todos los campos',
                        Colors.red,
                        Icons.error);
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
