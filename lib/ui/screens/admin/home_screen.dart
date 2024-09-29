import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:laboratorio/core/constants/app_colors.dart';
import 'package:laboratorio/data/repositories/material_repository.dart';
import 'package:laboratorio/ui/widgets/custom_snackbar.dart';
import 'package:laboratorio/ui/widgets/update_material_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:html' as html;

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
      Uint8List? bytes;

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
                await _materialRepo.addMaterial(materialName, stock, unit);
                print('Material "$materialName" subido correctamente.');
              } catch (e) {
                CustomSnackbar.show(context, 'Error al agregar el material: $e',
                    Colors.red, Icons.error);
              }
            } else {}
          }
        }

        CustomSnackbar.show(context, 'Material agregado correctamente.',
            Colors.green, Icons.check_circle);
      } else {}
    } else {}
  }

  Future<void> _exportMaterials() async {
    // Crear un nuevo archivo Excel
    var excel = Excel.createExcel();

    // Obtener una hoja
    Sheet sheetObject = excel['Materiales'];

    // Definir estilo de celdas
    CellStyle cellStyle = CellStyle(
      fontFamily: getFontFamily(FontFamily.Calibri),
      fontSize: 14,
      bold: true,
      underline: Underline.Single,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    // Escribir encabezados en la primera fila
    var headers = ['Indice', 'Material', 'Stock', 'UM'];
    for (int i = 0; i < headers.length; i++) {
      var cell = sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]); // Asignar el valor del encabezado
      cell.cellStyle = cellStyle; // Aplicar estilo
    }

    // Obtener datos desde Firebase Realtime Database
    DatabaseReference materialsRef =
        FirebaseDatabase.instance.ref().child('materiales');

    // Esperar a que se obtengan los datos
    DataSnapshot snapshot = await materialsRef.get();

    if (snapshot.exists) {
      Map<dynamic, dynamic> materialsMap =
          snapshot.value as Map<dynamic, dynamic>;

      int rowIndex = 1; // Comenzar desde la segunda fila
      int indicator = 1; // Contador para el indicador numérico
      materialsMap.forEach((key, value) {
        var material = value as Map<dynamic, dynamic>;

        // Escribir los valores en las celdas
        sheetObject
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
            .value = IntCellValue(indicator); // Indicador numérico
        sheetObject
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
            .value = TextCellValue(material['name']); // Nombre
        sheetObject
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
            .value = IntCellValue(material['stock']); // Stock
        sheetObject
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
            .value = TextCellValue(material['unit']); // Unidad

        rowIndex++;
        indicator++; // Incrementar el indicador
      });
    } else {
      print('No se encontraron materiales en Firebase.');
    }

    // Guardar el archivo
    if (kIsWeb) {
      final bytes = excel.encode();
      if (bytes != null) {
        final content = base64Encode(bytes);
        html.AnchorElement(
            href: "data:application/octet-stream;base64,$content")
          ..setAttribute("download", "materiales.xlsx")
          ..click();
      }
    } else {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/materiales.xlsx';
        final file = File(filePath);

        await file.writeAsBytes(excel.encode()!, flush: true);
        print('Archivo guardado en: $filePath');
      } catch (e) {
        print('Error al guardar el archivo: $e');
      }
    }
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
                    decoration: const InputDecoration(
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
              child: const Row(
                children: [
                  Expanded(
                      child: Text('Material',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(
                      child: Text('Stock',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(
                      child: Text('Unidad de medida',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(
                      child: Text('Acciones',
                          style: TextStyle(fontWeight: FontWeight.bold))),
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
                                        'id': material[
                                            'id'], // Asegúrate de que el ID esté aquí
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
