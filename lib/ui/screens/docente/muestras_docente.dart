import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:laboratorio/core/constants/app_colors.dart';
import 'package:laboratorio/data/models/muestra_model.dart';
import 'package:laboratorio/data/models/material.dart';
import 'package:laboratorio/data/repositories/solicitud_repository.dart';
import 'package:laboratorio/ui/widgets/auto_dismiss_alert.dart';
import 'package:laboratorio/ui/widgets/custom_textfield_docente.dart';
import 'package:laboratorio/ui/widgets/navigation_drawer.dart';

class MuestrasDocente extends StatefulWidget {
  const MuestrasDocente({super.key});

  @override
  _PracticeFormState createState() => _PracticeFormState();
}
class _PracticeFormState extends State<MuestrasDocente> {
  final SolicitudRepository _solicitudRepository = SolicitudRepository();
  final _titleController = TextEditingController();
  final _courseController = TextEditingController();
  final List<LabMaterial> _material = [];
  final bool _isValidStudentCount = true;
  bool _isConfirmed = false;
  DateTime? _selectedDate;
  DateTime? _selectedDateR;

  void _addMaterial() {
    setState(() {
      _material.add(
        const LabMaterial(name: '', quantity: '', unit: ''),
      );
    });
  }

  void _removeMaterial(int index) {
    setState(() {
      _material.removeAt(index);
    });
  }

  void _updateMaterial(int index, String name, String quantity, String unit) {
    setState(() {
      _material[index] = LabMaterial(
        name: name,
        quantity: quantity,
        unit: unit,
      );
    });
  }

  Future<void> _submitSolicitud() async {
    if (_isConfirmed &&
        _isValidStudentCount &&
        _titleController.text.isNotEmpty &&
        _courseController.text.isNotEmpty) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final muestra = Muestra(
          title: _titleController.text,
          course: _courseController.text,
          date: _selectedDate != null
              ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
              : null,
          dateR: _selectedDateR != null
              ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
              : null,
          muestras: _material
              .map((m) =>
                  LabMaterial(name: m.name, quantity: m.quantity, unit: m.unit))
              .toList(),
          userId: user.uid,
          estado: 'dejado',
        );

        try {
          await _solicitudRepository.createMuestra(muestra);
          // Mostrar mensaje de éxito
          showAutoDismissAlert(context, 'Se guardo correctamente',
              const Color.fromARGB(255, 41, 10, 112));
          // Vaciar campos
          setState(() {
            _titleController.clear();
            _courseController.clear();
            _selectedDate = null;
            _material.clear();
            _selectedDateR = null;
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
    
  }
  
  //seccion de curso, practica, alumnos, turno
  Widget build(BuildContext context) {
    return Scaffold(     
      appBar: const GlobalNavigationBar(),
          drawer: MediaQuery.of(context).size.width < 600
              ? const GlobalNavigationBar().buildCustomDrawer(context)
              : null, 
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomTextField(
              controller: _titleController,
              labelText: 'Experimento',
              validator: (value) =>
                  value!.isEmpty ? 'Ingrese el nombre del Experimento' : null,
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: _courseController,
              labelText: 'Nombre del Curso',
              validator: (value) =>
                  value!.isEmpty ? 'Ingrese el nombre del curso' : null,
            ),
            const SizedBox(height: 20),
            _buildDateTimeSection(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addMaterial,
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Agregar Muestras'),
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
              child: const Text('Registrar'),
            ),
          ],
        ),
      ),
    );
  }

//Seccion de fecha 
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
                  : 'Entrada',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        
      ],
    );
  }

//tabla  para agregar muestras
  Widget _buildMaterialsTable() {
    return _material.isEmpty
        ? const Text('No se han agregado muestras.')
        : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 10,
              columns: const [
                DataColumn(
                  label: Expanded(
                    child: Text(
                      'Muestra',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    child: Text(
                      'Cant.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    child: Text(
                      'Ubicacion',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    child: Text(
                      'Acción',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
              rows: _material.asMap().entries.map((entry) {
                int index = entry.key;
                LabMaterial material = entry.value;
                return DataRow(
                  cells: [
                    DataCell(
                      SizedBox(
                        width: 80,
                        child: TextFormField(
                          initialValue: material.name,
                          onChanged: (value) {
                            _updateMaterial(
                                index, value, material.quantity, material.unit);
                          },
                          decoration: const InputDecoration(),
                          maxLines: 1,
                          style: const TextStyle(fontSize: 14),
                          textAlignVertical: TextAlignVertical.center,
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 40,
                        child: TextFormField(
                          initialValue: material.quantity,
                          onChanged: (value) {
                            _updateMaterial(
                                index, material.name, value, material.unit);
                          },
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(),
                          maxLines: 1,
                          style: const TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 40,
                        child: TextFormField(
                          initialValue: material.unit,
                          onChanged: (String newValue) {
                            _updateMaterial(index, material.name,
                                material.quantity, newValue);
                          },
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(),
                          maxLines: 1,
                          style: const TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
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

//Seccion de confirmacion para solicitud
  Widget _buildConfirmationBox() {
    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.orange.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('¿Estás seguro guardar la informacion?'),
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
