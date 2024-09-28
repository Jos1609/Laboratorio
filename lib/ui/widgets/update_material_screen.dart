import 'package:flutter/material.dart';

class UpdateMaterialScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController(text: 'Tubos de ensayo');
  final TextEditingController stockController = TextEditingController(text: '20');
  final TextEditingController unitController = TextEditingController(text: 'ML');

  UpdateMaterialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Actualizar Material',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            // Nombre del material
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Nombre del Material'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              enabled: true, 
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[300], // Color de fondo gris
              ),
            ),
            const SizedBox(height: 20),
            // Campos de stock y unidad de medida en una fila
            Row(
              children: [
                // Stock
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Stock'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: stockController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // Unidad de medida
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Unidad de medida'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: unitController,
                        enabled: true, 
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.grey[300], // Color de fondo gris
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            // Botón Guardar
            ElevatedButton(
              onPressed: () {
                // Acción para guardar cambios
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15), backgroundColor: Colors.blue,
              ),
              child: const Text(
                'Guardar',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: UpdateMaterialScreen(),
  ));
}
