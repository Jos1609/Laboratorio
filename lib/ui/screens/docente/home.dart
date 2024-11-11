import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:laboratorio/core/constants/app_colors.dart';
import 'package:laboratorio/core/utils/validators.dart';
import 'package:laboratorio/data/models/solicitud_model.dart';
import 'package:laboratorio/data/models/material.dart';
import 'package:laboratorio/services/solicitud_service.dart';
import 'package:laboratorio/ui/widgets/auto_dismiss_alert.dart';
import 'package:laboratorio/ui/widgets/custom_navigation_bar.dart';
import 'package:laboratorio/ui/widgets/custom_textfield_docente.dart';
import 'package:laboratorio/ui/widgets/date_time_selector.dart';
import 'package:laboratorio/ui/widgets/materials_table.dart';

class HomeDocente1 extends StatefulWidget {
  const HomeDocente1({super.key});

  @override
  _HomeDocenteState createState() => _HomeDocenteState();
}

class _HomeDocenteState extends State<HomeDocente1> {
  final SolicitudService _solicitudService = SolicitudService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();
  final TextEditingController _studentCountController = TextEditingController();
  TimeOfDay? _startSlot;
  TimeOfDay? _endSlot;

  List<LabMaterial> _materials = [];
  Map<String, dynamic> _materialsData = {};
  String _selectedTurn = 'Seleccionar Turno';
  bool _isConfirmed = false;
  bool _isValidStudentCount = true;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadMaterialsData();
  }

  Future<void> _loadMaterialsData() async {
    final materialsData = await _solicitudService.loadMaterials();
    setState(() {
      _materialsData = materialsData;
    });
  }

  void _validateStudentCount(String value) {
    setState(() {
      _isValidStudentCount =
          Validators.isValidNumber(value) && int.tryParse(value) != 0;
    });
  }

  Future<void> _submitSolicitud() async {
    List<String> missingFields = [];

    if (_titleController.text.isEmpty) {
      missingFields.add("el Título de la práctica");
    }
    if (_courseController.text.isEmpty) {
      missingFields.add("el Nombre del Curso");
    }
    if (_studentCountController.text.isEmpty || !_isValidStudentCount) {
      missingFields.add("el Número de Estudiantes válido");
    }
    if (_selectedDate == null) {
      missingFields.add("la Fecha");
    }
    if (_startSlot == null || _endSlot == null) {
      missingFields.add("el Horario de la práctica");
    }

    if (missingFields.isEmpty && _isConfirmed) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final solicitud = Solicitud(
          title: _titleController.text,
          course: _courseController.text,
          studentCount: _studentCountController.text,
          turn: _selectedTurn,
          date:
              '${_selectedDate?.day}/${_selectedDate?.month}/${_selectedDate?.year}',
          startTime: _startSlot?.format(context),
          endTime: _endSlot?.format(context),
          materials: _materials,
          userId: user.uid,
        );
        try {
          await _solicitudService.saveSolicitud(solicitud);
          showAutoDismissAlert(
              context, 'Solicitud enviada correctamente', AppColors.primary);
          _resetForm();
        } catch (e) {
          showAutoDismissAlert(
              context, 'Error al enviar la solicitud', Colors.red);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario no autenticado')),
        );
      }
    } else {
      String errorMessage = "Por favor complete los siguientes campos: \n";
      errorMessage += missingFields.join(", \n");
      showAutoDismissAlert(context, errorMessage, Colors.red);
    }
  }

  void _resetForm() {
    setState(() {
      _titleController.clear();
      _courseController.clear();
      _studentCountController.clear();
      _selectedTurn = 'Seleccionar Turno';
      _selectedDate = null;
      _startSlot = null;
      _endSlot = null;
      _materials.clear();
      _isConfirmed = false;
    });
  }

  @override
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
                  items: ['Seleccionar Turno', 'Mañana', 'Tarde', 'Noche']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTurn = value!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            DateTimeSelector(
              solicitudService: _solicitudService,
              selectedTurn: _selectedTurn,
              onTimeSlotSelected: (start, end) {
                setState(() {
                  _startSlot = start;
                  _endSlot = end;
                });
              },
              onDateSelected: (date) {
                setState(() {
                  _selectedDate = date; // Actualizar la fecha seleccionada
                });
              },
            ),
            const SizedBox(height: 20),
            MaterialsTable(
              materials: _materials,
              materialsData: _materialsData,
              onMaterialsUpdated: (updatedMaterials) {
                setState(() {
                  _materials = updatedMaterials;
                });
              },
            ),
            const SizedBox(height: 20),
            _buildConfirmationBox(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isConfirmed ? _submitSolicitud : null,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('Solicitar'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomNavigationBar(),
    );
  }

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