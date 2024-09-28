import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:laboratorio/core/constants/app_colors.dart';
import 'package:laboratorio/data/repositories/material_repository.dart';
import 'package:laboratorio/ui/widgets/update_material_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:file_picker/file_picker.dart';
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
  List<Map<dynamic, dynamic>> filteredMaterials = [];
  String searchQuery = "";

  @override
  void initState() {
    _testFirebaseConnection();
    super.initState();
    _materialRef = FirebaseDatabase.instance.ref().child('materiales');
    _materialRef.onValue.listen((event) {
      final data = event.snapshot.value != null
          ? Map<dynamic, dynamic>.from(event.snapshot.value as Map)
          : {};
      setState(() {
        materials = data.entries.map((entry) {
          // Asegúrate de que cada material tenga un ID
          return {
            'id': entry.key, // Aquí estamos asignando el ID
            'name': entry.value['name'],
            'stock': entry.value['stock'],
            'unit': entry.value['unit'],
          };
        }).toList();
        _filterMaterials(); // Filtrar materiales después de cargar los datos
      });
    });
  }

  Future<void> _testFirebaseConnection() async {
    try {
      DatabaseEvent event = await FirebaseDatabase.instance
          .ref('materiales')
          .limitToFirst(1)
          .once();
      print('Test query result: ${event.snapshot.value}');
    } catch (e) {
      print('Error en test query: $e');
    }
  }

  void _filterMaterials() {
    setState(() {
      filteredMaterials = materials
          .where((material) => material['name']
              .toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase()))
          .toList();
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      searchQuery = value;
      _filterMaterials();
    });
  }

  // Import materials from an Excel file and upload to Firebase
  void _importMaterials() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null && result.files.isNotEmpty) {
      var bytes;

      // Verificar si estamos en la web
      if (kIsWeb) {
        bytes = result.files.first.bytes;
      } else {
        String? filePath = result.files.single.path;
        if (filePath != null) {
          bytes = File(filePath).readAsBytesSync();
        }
      }

      if (bytes != null) {
        var excel = Excel.decodeBytes(bytes);

        for (var table in excel.tables.keys) {
          for (var row in excel.tables[table]!.rows) {
            String materialName = row[0]?.value?.toString() ?? '';
            int? stock = (row[1]?.value is int)
                ? (row[1]?.value as int)
                : int.tryParse(row[1]?.value?.toString() ?? '');
            String unit = row[2]?.value?.toString() ?? '';

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
      } else {
        print("No se pudo leer el contenido del archivo.");
      }
    } else {
      print("No se seleccionó ningún archivo.");
    }
  }

  Future<void> _exportMaterials() async {
    // Implementar la lógica de exportación aquí
  }

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextField(
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      labelText: 'Buscar material',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _exportMaterials,
                  icon: const Icon(Icons.download),
                  label: const Text('Exportar'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              color: Colors.grey[300],
              child: Row(
                children: const [
                  Expanded(child: Text('Material', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(child: Text('Stock', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(child: Text('Unidad de medida', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(child: Text('Acciones', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
            ),
            const Divider(height: 2),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: filteredMaterials.map((material) {
                    return Row(
                      children: [
                        Expanded(child: Text(material['name'])),
                        Expanded(child: Text(material['stock'].toString())),
                        Expanded(child: Text(material['unit'])),
                        Expanded(
                          child: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  // Usar el mapa material aquí
                                  return Dialog(
                                    child: UpdateMaterialCard(
                                      material: {
                                        'id': material['id'], // Asegúrate de que el ID esté aquí
                                        'name': material['name'],
                                        'stock': material['stock'],
                                        'unit': material['unit'],
                                      },
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    );
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
