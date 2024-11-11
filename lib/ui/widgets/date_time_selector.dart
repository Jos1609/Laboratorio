import 'package:flutter/material.dart';
import 'package:laboratorio/data/repositories/solicitud_repository.dart';
import 'package:laboratorio/services/solicitud_service.dart';

class DateTimeSelector extends StatefulWidget {
  final SolicitudService solicitudService;
  final Function(TimeOfDay start, TimeOfDay end) onTimeSlotSelected;
  final Function(DateTime?) onDateSelected;
  final String selectedTurn;

  const DateTimeSelector({
    super.key,
    required this.solicitudService,
    required this.onTimeSlotSelected,
    required this.onDateSelected,
    required this.selectedTurn,
  });

  @override
  _DateTimeSelectorState createState() => _DateTimeSelectorState();
}

class _DateTimeSelectorState extends State<DateTimeSelector> {
  DateTime? selectedDate;
  List<String> selectedSlots = [];
  List<Map<String, dynamic>> availableTimeSlots = [];
  List<TimeOfDay> occupiedSlots = [];
  bool _isLoading = false;
  final SolicitudRepository _solicitudRepository = SolicitudRepository();

  @override
  void initState() {
    super.initState();
    _initializeTimeSlots();
  }

  void _initializeTimeSlots() {
    availableTimeSlots = [
      {
        'turn': 'Mañana',
        'slots': ['7:00 - 8:20', '8:30 - 10:00', '10:15 - 11:45']
      },
      {
        'turn': 'Tarde',
        'slots': ['12:00 - 1:30', '2:00 - 3:30', '3:45 - 5:15']
      },
      {
        'turn': 'Noche',
        'slots': ['5:30 - 7:00', '7:10 - 8:40', '8:50 - 10:20']
      },
    ];
  }

  List<String> getSlotsForTurn() {
    if (widget.selectedTurn == 'Seleccionar Turno') {
      return []; // Devuelve una lista vacía si el turno no es válido
    }
    // Filtra los horarios por el turno seleccionado
    return availableTimeSlots
        .firstWhere((slot) => slot['turn'] == widget.selectedTurn)['slots']
        .cast<String>();
  }

  void _onSlotTapped(String slot) {
    final start = _parseTimeOfDay(slot.split(" - ")[0]);
    final end = _parseTimeOfDay(slot.split(" - ")[1]);

    // Verificar si el horario está ocupado
    if (occupiedSlots.contains(start)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este horario ya está ocupado')),
      );
      return;
    }

    setState(() {
      if (selectedSlots.contains(slot)) {
        selectedSlots.remove(slot);
      } else if (selectedSlots.isEmpty || _isConsecutive(slot)) {
        selectedSlots.add(slot);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seleccione horarios consecutivos')),
        );
      }
    });

    if (selectedSlots.isNotEmpty) {
      widget.onTimeSlotSelected(start, end);
    }
  }

  bool _isConsecutive(String slot) {
    if (selectedSlots.isEmpty) return true;
    final lastSelectedEnd = _parseTimeOfDay(selectedSlots.last.split(" - ")[1]);
    final newSlotStart = _parseTimeOfDay(slot.split(" - ")[0]);
    return newSlotStart.hour == lastSelectedEnd.hour &&
        newSlotStart.minute == lastSelectedEnd.minute + 10;
  }

  TimeOfDay _parseTimeOfDay(String timeStr) {
    final parts = timeStr.split(RegExp(r'[:\s]'));
    if (parts.length < 2) {
      throw FormatException('Formato de hora inválido: $timeStr');
    }

    final hour = int.tryParse(parts[0]) ??
        (throw FormatException('Hora inválida: ${parts[0]}'));
    final minute = int.tryParse(parts[1]) ??
        (throw FormatException('Minutos inválidos: ${parts[1]}'));
    final period = parts.length > 2 ? parts[2].toUpperCase() : '';

    if (period == 'PM' && hour != 12) {
      return TimeOfDay(hour: hour + 12, minute: minute);
    } else if (period == 'AM' && hour == 12) {
      return TimeOfDay(hour: 0, minute: minute);
    } else if (period == '') {
      // Si no hay período, determinar según el turno seleccionado
      if (widget.selectedTurn == 'Mañana') {
        return TimeOfDay(hour: hour, minute: minute);
      } else {
        return TimeOfDay(hour: hour + 12, minute: minute);
      }
    } else {
      return TimeOfDay(hour: hour, minute: minute);
    }
  }

  Future<void> _loadOccupiedSlots(DateTime date) async {
    setState(() {
      _isLoading = true; // Empieza a cargar
    });
    try {
      final solicitudesExistentes =
          await _solicitudRepository.getSolicitudesByDate(date);
      setState(() {
        occupiedSlots = solicitudesExistentes
            .map((solicitud) => _parseTimeOfDay(solicitud.startTime!))
            .toList();
      });
    } catch (e) {
      print("Error al cargar los horarios ocupados: $e");
    } finally {
      setState(() {
        _isLoading = false; // Termina de cargar
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final slotsForTurn = getSlotsForTurn();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: IconButton(
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
                  selectedDate = pickedDate;
                  selectedSlots.clear();
                });
                widget.onDateSelected(selectedDate);
                await _loadOccupiedSlots(selectedDate!);
              }
            },
          ),
        ),
        if (_isLoading)
          const CircularProgressIndicator()
        else
          Text(selectedDate != null
              ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
              : 'Seleccione Fecha'),
        const SizedBox(height: 10),
        if (slotsForTurn.isNotEmpty) // Mostrar solo si hay horarios
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: slotsForTurn.map<Widget>((time) {
              final startTime = _parseTimeOfDay(time.split(" - ")[0]);
              final isOccupied = occupiedSlots.contains(startTime);
              final isSelected = selectedSlots.contains(time);

              return GestureDetector(
                onTap: isOccupied ? null : () => _onSlotTapped(time),
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: isOccupied
                        ? Colors.red.withOpacity(0.5)
                        : isSelected
                            ? Colors.blue
                            : Colors.grey[300],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    time,
                    style: TextStyle(
                      color: isOccupied
                          ? Colors.white
                          : isSelected
                              ? Colors.white
                              : Colors.black,
                      fontWeight: isOccupied
                          ? FontWeight.bold
                          : isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          )
        else
          const Text('Seleccione un turno para ver los horarios disponibles'),
      ],
    );
  }
}
