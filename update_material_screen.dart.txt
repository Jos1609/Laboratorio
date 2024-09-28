// Ubicación del archivo: lib/ui/widgets/update_material_screen.dart
import 'package:flutter/material.dart';
import 'package:laboratorio/data/repositories/material_repository.dart';

class UpdateMaterialScreen extends StatelessWidget {
  final Map material;

  const UpdateMaterialScreen({super.key, required this.material});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController(text: material['name']);
    final TextEditingController stockController = TextEditingController(text: material['stock'].toString());
    final TextEditingController unitController = TextEditingController(text: material['unit']);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Nombre del material'),
          ),
          TextField(
            controller: stockController,
            decoration: const InputDecoration(labelText: 'Stock'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: unitController,
            decoration: const InputDecoration(labelText: 'Unidad de medida'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              final updatedData = {
                'name': nameController.text,
                'stock': int.parse(stockController.text),
                'unit': unitController.text,
              };
              MaterialRepository().updateMaterial(material['id'], updatedData);
              Navigator.pop(context);
            },
            child: const Text('Guardar cambios'),
          ),
        ],
      ),
    );
  }
}
