import 'package:flutter/material.dart';
import 'package:laboratorio/core/constants/app_colors.dart';
import 'package:laboratorio/data/repositories/material_repository.dart';
import 'package:laboratorio/ui/widgets/update_material_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:file_picker/file_picker.dart';
//import 'package:path_provider/path_provider.dart';
//import 'package:permission_handler/permission_handler.dart';

import 'dart:io';
import 'package:excel/excel.dart';

class HomeAdminScreen extends StatefulWidget {
  const HomeAdminScreen({super.key});

  @override
  _HomeAdminScreenState createState() => _HomeAdminScreenState();
}

class _HomeAdminScreenState extends State<HomeAdminScreen> {
  final MaterialRepository _materialRepo = MaterialRepository();
  late DatabaseReference _materialRef;
  List<Map<dynamic, dynamic>> materials = [];

  @override
  void initState() {
    super.initState();
    _materialRef = FirebaseDatabase.instance.ref().child('materiales');
    _materialRef.onValue.listen((event) {
      final data = event.snapshot.value != null
          ? Map<dynamic, dynamic>.from(event.snapshot.value as Map)
          : {};
      setState(() {
        materials = data.values.toList().cast<Map<dynamic, dynamic>>();
      });
    });
  }

  // Import materials from an Excel file and upload to Firebase
  void _importMaterials() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      var bytes = File(result.files.single.path!).readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);

      for (var table in excel.tables.keys) {
        for (var row in excel.tables[table]!.rows) {
          // Acceder al valor directamente desde la propiedad .value de la celda
          String materialName =
              row[0]?.value?.toString() ?? ''; // Convertir a String
          int? stock = (row[1]?.value is int)
              ? (row[1]?.value as int)
              : int.tryParse(row[1]?.value?.toString() ??
                  ''); // Convertir a int si es necesario
          String unit = row[2]?.value?.toString() ?? ''; // Convertir a String

          // Validar que los datos no sean nulos o vacíos
          if (materialName.isNotEmpty && stock != null && unit.isNotEmpty) {
            try {
              print(
                  'Subiendo material: $materialName, stock: $stock, unit: $unit');
              await _materialRepo.addMaterial(materialName, stock, unit);
              print('Material "$materialName" subido correctamente.');
            } catch (e) {
              print('Error al subir el material "$materialName": $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error al subir el material: $materialName'),
                ),
              );
            }
          } else {
            print('Datos inválidos en la fila: $row');
          }
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Datos subidos exitosamente!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _exportMaterials() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: AppColors.mainColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: ElevatedButton.icon(
                onPressed: _exportMaterials,
                icon: const Icon(Icons.download),
                label: const Text('Exportar'),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: materials.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay materiales',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Material')),
                          DataColumn(label: Text('Stock')),
                          DataColumn(label: Text('Unidad de medida')),
                          DataColumn(label: Text('Acciones')),
                        ],
                        rows: materials.map((material) {
                          return DataRow(cells: [
                            DataCell(Text(material['name'])),
                            DataCell(Text(material['stock'].toString())),
                            DataCell(Text(material['unit'])),
                            DataCell(
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Dialog(
                                        child: UpdateMaterialScreen(
                                            material: material),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ]);
                        }).toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _importMaterials,
        child: const Icon(Icons.add),
      ),
    );
  }
}
