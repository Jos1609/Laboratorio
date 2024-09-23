import 'package:flutter/material.dart';
import 'package:laboratorio/ui/widgets/ResponsiveNavBar.dart';
import 'package:laboratorio/ui/widgets/update_material_screen.dart';

class HomeAdminScreen extends StatelessWidget {
  const HomeAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: Colors.purple,
        actions: [
          // El buscador siempre visible
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Lógica del buscador
            },
          ),
        ],
      ),
      // Drawer para mostrar el menú lateral
      drawer: const Drawer(
        child: ResponsiveNavBar(), // Menú lateral que se puede desplegar
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Botón de exportar
            Align(
              alignment: Alignment.topRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Lógica para exportar datos
                },
                icon: const Icon(Icons.download),
                label: const Text('Exportar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Tabla centrada
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Material')),
                      DataColumn(label: Text('Stock')),
                      DataColumn(label: Text('Unidad de medida')),
                      DataColumn(label: Text('Acciones')),
                    ],
                    rows: [
                      DataRow(cells: [
                        const DataCell(Text('Tubo de ensayo')),
                        const DataCell(Text('20')),
                        const DataCell(Text('ml')),
                        DataCell(
                          TextButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: SingleChildScrollView(
                                      child: Container(
                                        width: MediaQuery.of(context)
                                                .size
                                                .width *
                                            0.8, // Ajusta el ancho según necesites
                                        height: MediaQuery.of(context)
                                                .size
                                                .height *
                                            0.9, // Ajusta la altura según necesites
                                        padding: const EdgeInsets.all(16.0),
                                        child: UpdateMaterialScreen(),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            icon: const Icon(Icons.edit, size: 16),
                            label: const Text('Editar'),
                          ),
                        ),
                      ]),
                      // Añade más filas de materiales aquí
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // Botón flotante para agregar nuevos materiales
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Lógica para añadir nuevo material
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
    );
  }
}
