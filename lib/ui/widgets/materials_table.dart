import 'package:flutter/material.dart';
import 'package:laboratorio/data/models/material.dart';

class MaterialsTable extends StatefulWidget {
  final List<LabMaterial> materials;
  final Map<String, dynamic> materialsData;
  final ValueChanged<List<LabMaterial>> onMaterialsUpdated;

  MaterialsTable({
    required this.materials,
    required this.materialsData,
    required this.onMaterialsUpdated,
  });

  @override
  _MaterialsTableState createState() => _MaterialsTableState();
}

class _MaterialsTableState extends State<MaterialsTable> {
  final List<TextEditingController> _quantityControllers = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    for (var material in widget.materials) {
      _quantityControllers.add(TextEditingController(text: material.quantity));
    }
  }

  void _addMaterialRow() {
    setState(() {
      widget.materials
          .add(LabMaterial(name: '', quantity: '1', unit: 'Unidad'));
      _quantityControllers.add(TextEditingController(text: '1'));
      widget.onMaterialsUpdated(widget.materials);
    });
  }

  void _removeMaterialRow(int index) {
    setState(() {
      widget.materials.removeAt(index);
      _quantityControllers.removeAt(index);
      widget.onMaterialsUpdated(widget.materials);
    });
  }

  void _updateMaterialQuantity(int index, String quantity) {
    setState(() {
      widget.materials[index] = LabMaterial(
        name: widget.materials[index].name,
        quantity: quantity,
        unit: widget.materials[index].unit,
      );
      widget.onMaterialsUpdated(widget.materials);
    });
  }

  void _updateMaterialName(int index, String name, String unit) {
    setState(() {
      widget.materials[index] = LabMaterial(
        name: name,
        quantity: widget.materials[index].quantity,
        unit: unit,
      );
      widget.onMaterialsUpdated(widget.materials);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints:
                BoxConstraints(minWidth: MediaQuery.of(context).size.width),
            child: DataTable(
              columnSpacing: 10,
              columns: const [
                DataColumn(
                    label: Text('Material', style: TextStyle(fontSize: 12))),
                DataColumn(
                    label: Text('Cant.', style: TextStyle(fontSize: 12))),
                DataColumn(
                    label: Text('Estado', style: TextStyle(fontSize: 12))),
                DataColumn(
                    label: Text('Acción', style: TextStyle(fontSize: 12))),
              ],
              rows: widget.materials.asMap().entries.map((entry) {
                int index = entry.key;
                LabMaterial material = entry.value;

                if (_quantityControllers.length <= index) {
                  _quantityControllers
                      .add(TextEditingController(text: material.quantity));
                }

                // Obtener el ID del material actual
                String currentMaterialId = widget.materialsData.keys.firstWhere(
                  (key) => widget.materialsData[key]?['name'] == material.name,
                  orElse: () => '',
                );

                // Verificar si hay stock disponible
                int availableQuantity = widget.materialsData[currentMaterialId]
                        ?['quantity'] as int? ??
                    0;
                bool hasStock = availableQuantity > 0;

                return DataRow(
                  cells: [
                    DataCell(
                      Container(
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width *
                                0.5), // Limitar el ancho
                        child: Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return const Iterable<String>.empty();
                            }
                            // Filtrar solo materiales con stock disponible
                            return widget.materialsData.values.where((option) {
                              return option['name'].toLowerCase().contains(
                                        textEditingValue.text.toLowerCase(),
                                      ) &&
                                  (option['quantity'] as int? ?? 0) > 0;
                            }).map((option) => option['name'] as String);
                          },
                          onSelected: (String selectedMaterial) {
                            String selectedId =
                                widget.materialsData.keys.firstWhere(
                              (key) =>
                                  widget.materialsData[key]?['name'] ==
                                  selectedMaterial,
                              orElse: () => '',
                            );
                            int availableQuantity =
                                widget.materialsData[selectedId]?['quantity']
                                        as int? ??
                                    0;
                            String selectedUnit =
                                widget.materialsData[selectedId]?['unit']
                                        as String? ??
                                    'Unidad';

                            // Solo permitir selección si hay stock
                            if (availableQuantity > 0) {
                              _updateMaterialName(
                                  index, selectedMaterial, selectedUnit);
                              _quantityControllers[index].text = '1';
                            }
                          },
                          fieldViewBuilder: (context, textEditingController,
                              focusNode, onFieldSubmitted) {
                            return TextFormField(
                              controller: textEditingController,
                              focusNode: focusNode,
                              decoration: const InputDecoration(
                                hintText: 'Buscar Material',
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 8),
                              ),
                              style: const TextStyle(fontSize: 14),
                              maxLines: 1, // Limitar a una sola línea
                               // Ajustar el texto y añadir "..." si es demasiado largo
                            );
                          },
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 60,
                        child: TextFormField(
                          controller: _quantityControllers[index],
                          onChanged: (value) {
                            int? enteredQuantity = int.tryParse(value);
                            if (currentMaterialId.isNotEmpty &&
                                enteredQuantity != null) {
                              if (enteredQuantity > availableQuantity) {
                                _quantityControllers[index].text =
                                    availableQuantity.toString();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Cantidad máxima: $availableQuantity'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              } else if (enteredQuantity > 0) {
                                _updateMaterialQuantity(index, value);
                              } else {
                                _quantityControllers[index].text = '1';
                                _updateMaterialQuantity(index, '1');
                              }
                            }
                          },
                          keyboardType: TextInputType.number,
                          enabled: hasStock,
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 8),
                          ),
                          maxLines: 1,
                          style: const TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: hasStock
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          hasStock ? 'Disponible' : 'Sin Stock',
                          style: TextStyle(
                            fontSize: 12,
                            color: hasStock ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.delete,
                            color: Colors.red, size: 20),
                        onPressed: () => _removeMaterialRow(index),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _addMaterialRow,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          child: const Text('Agregar Materiales'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    for (var controller in _quantityControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
