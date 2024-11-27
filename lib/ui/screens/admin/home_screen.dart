import 'package:flutter/material.dart';
import 'package:laboratorio/data/repositories/material_repository.dart';
import 'package:laboratorio/ui/widgets/update_material_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:laboratorio/ui/widgets/navigation_drawer.dart';
import 'package:laboratorio/services/material_importer.dart';
import 'package:laboratorio/services/material_exporter.dart';

class HomeAdminScreen extends StatefulWidget {
  const HomeAdminScreen({super.key});

  @override
  _HomeAdminScreenState createState() => _HomeAdminScreenState();
}

class _HomeAdminScreenState extends State<HomeAdminScreen> {
    late final MaterialRepository _materialRepo;
  late final MaterialImporter _materialImporter;
  late final MaterialExporter _materialExporter;
  late DatabaseReference _materialRef;
  List<Map<dynamic, dynamic>> materials = [];
  List<Map<dynamic, dynamic>> filteredMaterials = [];
  String searchQuery = "";
  int currentPage = 0;
  final int itemsPerPage = 15;

  @override
  void initState() {
    _testFirebaseConnection();
    super.initState();
    _materialRepo = MaterialRepository();
    _materialImporter = MaterialImporter(_materialRepo);
    _materialExporter = MaterialExporter();
    _materialRef = FirebaseDatabase.instance.ref().child('materiales');
    _materialRef.onValue.listen((event) {
      final data = event.snapshot.value != null
          ? Map<dynamic, dynamic>.from(event.snapshot.value as Map)
          : {};
      setState(() {
        materials = data.entries.map((entry) {
          return {
            'id': entry.key,
            'name': entry.value['name'],
            'stock': entry.value['stock'],
            'unit': entry.value['unit'],
          };
        }).toList();
        _filterMaterials();
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
      final searchResults = materials
          .where((material) => material['name']
              .toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase()))
          .toList();

      int start = currentPage * itemsPerPage;
      int end = start + itemsPerPage;

      filteredMaterials = searchResults.sublist(
        start,
        end > searchResults.length ? searchResults.length : end,
      );
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      searchQuery = value;
      currentPage = 0;
      _filterMaterials();
    });
  }

  void _importMaterials() async {
    await _materialImporter.importMaterials(context);
  }

  Future<void> _exportMaterials() async {
    await _materialExporter.exportMaterials();
  }

  void _goToPreviousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
        _filterMaterials();
      });
    }
  }

  void _goToNextPage() {
    final maxPage = (materials.length / itemsPerPage).ceil() - 1;
    if (currentPage < maxPage) {
      setState(() {
        currentPage++;
        _filterMaterials();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalNavigationBar(),
      drawer: MediaQuery.of(context).size.width < 600
          ? GlobalNavigationBar().buildCustomDrawer(context)
          : null,
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
                      child: Text('cantidad',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(
                      child: Text('Estado',
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
                                  return Dialog(
                                    child: UpdateMaterialCard(
                                      material: {
                                        'id': material['id'],
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _goToPreviousPage,
                ),
                Text('Pag. ${currentPage + 1}'),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _goToNextPage,
                ),
              ],
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