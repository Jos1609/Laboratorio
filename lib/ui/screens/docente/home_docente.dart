import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:laboratorio/core/constants/app_colors.dart';
import 'package:laboratorio/core/utils/validators.dart';
import 'package:laboratorio/data/models/solicitud_model.dart';
import 'package:laboratorio/data/models/material.dart';
import 'package:laboratorio/data/repositories/solicitud_repository.dart';
import 'package:laboratorio/ui/widgets/auto_dismiss_alert.dart';
import 'package:laboratorio/ui/widgets/custom_navigation_bar.dart';
import 'package:laboratorio/ui/widgets/custom_textfield_docente.dart';

final List<TextEditingController> _quantityControllers = [];

class HomeDocente extends StatefulWidget {
  const HomeDocente({super.key});

  @override
  _PracticeFormState createState() => _PracticeFormState();
}

class _PracticeFormState extends State<HomeDocente> {
  final SolicitudRepository _solicitudRepository = SolicitudRepository();
  final _titleController = TextEditingController();
  final _courseController = TextEditingController();
  final _studentCountController = TextEditingController();
  String _selectedTurn = 'Mañana';
  final List<LabMaterial> _materials = [];
  bool _isValidStudentCount = true;
  bool _isConfirmed = false;
  DateTime? _selectedDate;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;
  Map<String, dynamic> _materialsData = {};

  void _addMaterial() {
    setState(() {
      _materials.add(
        const LabMaterial(name: '', quantity: '', unit: 'Unidad'),
      );
    });
  }

  void _removeMaterial(int index) {
    setState(() {
      _materials.removeAt(index);
    });
  }

  void _validateStudentCount(String value) {
    setState(() {
      _isValidStudentCount =
          Validators.isValidNumber(value) && int.tryParse(value) != 0;
    });
  }

  void _updateMaterial(int index, String id, String quantity, String unit) {
    setState(() {
      _materials[index] = LabMaterial(
        name: _materialsData[id]?['name'] ?? '',
        quantity: quantity,
        unit: unit,
      );
    });
  }

  Future<void> _submitSolicitud() async {
    if (_isConfirmed &&
        _isValidStudentCount &&
        _titleController.text.isNotEmpty &&
        _courseController.text.isNotEmpty &&
        _studentCountController.text.isNotEmpty) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final solicitud = Solicitud(
          title: _titleController.text,
          course: _courseController.text,
          studentCount: _studentCountController.text,
          turn: _selectedTurn,
          date: _selectedDate != null
              ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
              : null,
          startTime: _selectedStartTime?.format(context),
          endTime: _selectedEndTime?.format(context),
          materials: _materials 
              .map((m) =>
                  LabMaterial(name: m.name, quantity: m.quantity, unit: m.unit))
              .toList(),
          userId: user.uid,
        );

        try {
          await _solicitudRepository.createSolicitud(solicitud);          
          // Mostrar mensaje de éxito
          showAutoDismissAlert(context, 'Se envió correctamente la solicitud',
              const Color.fromARGB(255, 41, 10, 112));

          // Vaciar campos
          setState(() {
            _titleController.clear();
            _courseController.clear();
            _studentCountController.clear();
            _selectedTurn = 'Mañana';
            _selectedDate = null;
            _selectedStartTime = null;
            _selectedEndTime = null;
            _materials.clear();
            _isConfirmed = false;
          });
        } catch (e) {
          showAutoDismissAlert(context, 'No se pudo enviar la solicitud',
              const Color.fromARGB(255, 227, 6, 6));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario no autenticado')),
        );
      }
    } else {
      showAutoDismissAlert(context, 'Complete todos los datos',
          const Color.fromARGB(255, 227, 6, 6));
    }
  }

  @override
  void initState() {
    super.initState();
    _loadMaterialsFromFirebase();
  }

  Future<void> _loadMaterialsFromFirebase() async {
    final DatabaseReference materialsRef =
        FirebaseDatabase.instance.ref().child('materiales');
    final DataSnapshot snapshot = await materialsRef.get();

    if (snapshot.exists) {
      Map<dynamic, dynamic> materialsMap =
          snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        _materialsData = materialsMap.map((key, value) {
          return MapEntry(key as String, {
            'name': value['name'] as String? ?? '',
            'quantity': value['stock'] as int? ?? 0,
            'unit': value['unit'] as String? ?? '',
          });
        });
      });
    }
  }

  //seccion de curso, practica, alumnos, turno
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomTextField(
              controller: _titleController,
              labelText: 'Título de la práctica',
              validator: (value) =>
                  value!.isEmpty ? 'Ingrese el título de la práctica' : null,
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: _courseController,
              labelText: 'Nombre del Curso',
              validator: (value) =>
                  value!.isEmpty ? 'Ingrese el nombre del curso' : null,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _studentCountController,
                    labelText: 'N° Est',
                    validator: (value) {
                      _validateStudentCount(value!);
                      return _isValidStudentCount ? null : 'Cantidad inválida';
                    },
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _selectedTurn,
                  items: ['Mañana', 'Tarde', 'Noche'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedTurn = newValue!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDateTimeSection(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addMaterial,
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Agregar Materiales'),
            ),
            const SizedBox(height: 20),
            _buildMaterialsTable(),
            const SizedBox(height: 20),
            _buildConfirmationBox(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isConfirmed ? _submitSolicitud : null,
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 80, 203, 225)),
              child: const Text('Solicitar'),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          const CustomNavigationBar(), //llamamos a la barra de navegacion
    );
  }

//Seccion de fecha y hora
  Widget _buildDateTimeSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // Campo para la Fecha
        Column(
          children: [
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  setState(() {
                    _selectedDate = pickedDate;
                  });
                }
              },
            ),
            Text(
              _selectedDate != null
                  ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                  : 'Fecha',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        // Campo para la Hora de inicio
        Column(
          children: [
            IconButton(
              icon: const Icon(Icons.access_time),
              onPressed: () async {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: const TimeOfDay(hour: 07, minute: 00),
                );
                if (pickedTime != null) {
                  setState(() {
                    _selectedStartTime = pickedTime;
                  });
                }
              },
            ),
            Text(
              _selectedStartTime != null
                  ? _selectedStartTime!.format(context)
                  : 'Inicio',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        // Campo para la Hora de fin
        Column(
          children: [
            IconButton(
              icon: const Icon(Icons.access_time),
              onPressed: () async {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: const TimeOfDay(hour: 22, minute: 20),
                );
                if (pickedTime != null) {
                  setState(() {
                    _selectedEndTime = pickedTime;
                  });
                }
              },
            ),
            Text(
              _selectedEndTime != null
                  ? _selectedEndTime!.format(context)
                  : 'Fin',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

//tabla  para agregar materiales
  Widget _buildMaterialsTable() {
    return _materials.isEmpty
        ? const Text('No se han agregado materiales.')
        : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 10,
              columns: const [
                DataColumn(
                    label: Text('Material', style: TextStyle(fontSize: 12))),
                DataColumn(
                    label: Text('Cant.', style: TextStyle(fontSize: 12))),
                DataColumn(label: Text('UM', style: TextStyle(fontSize: 12))),
                DataColumn(
                    label: Text('Acción', style: TextStyle(fontSize: 12))),
              ],
              rows: _materials.asMap().entries.map((entry) {
                int index = entry.key;
                LabMaterial material = entry.value;
                if (_quantityControllers.length <= index) {
                  _quantityControllers.add(TextEditingController(text: material.quantity));
                }
                return DataRow(
                  cells: [
                    DataCell(
                      Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return const Iterable<String>.empty();
                          }
                          return _materialsData.values.where((dynamic option) {
                            return option['name']
                                .toLowerCase()
                                .contains(textEditingValue.text.toLowerCase());
                          }).map((dynamic option) => option['name'] as String);
                        },
                        onSelected: (String selectedMaterial) {
                          String selectedId = _materialsData.keys.firstWhere(
                            (key) =>
                                _materialsData[key]?['name'] ==
                                selectedMaterial,
                            orElse: () => '',
                          );
                          int availableQuantity =
                              _materialsData[selectedId]?['quantity'] as int? ??
                                  0;
                          String selectedUnit =
                              _materialsData[selectedId]?['unit'] as String? ??
                                  'Unidad';

                          if (availableQuantity == 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Este material está sin stock.')),
                            );
                          }

                          _updateMaterial(index, selectedId,
                              availableQuantity.toString(), selectedUnit);
                        },
                        fieldViewBuilder: (context, textEditingController,
                            focusNode, onFieldSubmitted) {
                          return TextFormField(
                            controller: textEditingController,
                            focusNode: focusNode,
                            decoration: const InputDecoration(
                                hintText: 'Buscar Material'),
                            onFieldSubmitted: (String value) {
                              onFieldSubmitted();
                            },
                          );
                        },
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 60,
                        child: TextFormField(
                          controller: _quantityControllers[index],
                          onChanged: (value) {
                            int? enteredQuantity = int.tryParse(value);
                            String selectedId = _materialsData.keys.firstWhere(
                              (key) =>
                                  _materialsData[key]?['name'] == material.name,
                              orElse: () => '',
                            );
                            if (selectedId.isNotEmpty) {
                              int availableQuantity = _materialsData[selectedId]
                                      ?['quantity'] as int? ??
                                  0;
                              if (enteredQuantity != null &&
                                  enteredQuantity > availableQuantity) {
                                // Actualiza el valor del campo a la cantidad máxima
                                _quantityControllers[index].text =
                                    availableQuantity.toString();
                                // Mueve el cursor al final del texto
                                _quantityControllers[index].selection =
                                    TextSelection.fromPosition(
                                  TextPosition(
                                      offset:
                                          availableQuantity.toString().length),
                                );
                                _updateMaterial(
                                    index,
                                    selectedId,
                                    availableQuantity.toString(),
                                    material.unit);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Cantidad máxima: $availableQuantity')),
                                );
                              } else {
                                _updateMaterial(
                                    index, selectedId, value, material.unit);
                              }
                            }
                          },
                          keyboardType: TextInputType.number,
                          enabled:
                              (_materialsData[_materialsData.keys.firstWhere(
                                        (key) =>
                                            _materialsData[key]?['name'] ==
                                            material.name,
                                        orElse: () => '',
                                      )]?['quantity'] as int? ??
                                      0) >
                                  0,
                          decoration: InputDecoration(
                            errorText:
                                (_materialsData[_materialsData.keys.firstWhere(
                                              (key) =>
                                                  _materialsData[key]
                                                      ?['name'] ==
                                                  material.name,
                                              orElse: () => '',
                                            )]?['quantity'] as int? ??
                                            0) ==
                                        0
                                    ? 'Sin stock'
                                    : null,
                          ),
                          maxLines: 1,
                          style: const TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(material.unit),
                    ),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.delete,
                            color: Colors.red, size: 20),
                        onPressed: () => _removeMaterial(index),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          );
  }
 @override
  void dispose() {
    for (var controller in _quantityControllers) {
      controller.dispose();
    }
    super.dispose();
  } 

//Seccion de confirmacion para solicitud
  Widget _buildConfirmationBox() {
    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.orange.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('¿Estás seguro de hacer la solicitud?'),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Radio(
                value: true,
                groupValue: _isConfirmed,
                onChanged: (bool? value) {
                  setState(() {
                    _isConfirmed = value!;
                  });
                },
              ),
              const Text('Confirmar'),
            ],
          ),
        ],
      ),
    );
  }

}
