import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:laboratorio/ui/screens/docente/home.dart';
import '../../../data/models/solicitud_model.dart';
import 'package:laboratorio/ui/widgets/navigation_drawer.dart';
import 'package:intl/intl.dart';
import 'package:laboratorio/ui/widgets/solicitud_card.dart';

class SolicitudesScreen extends StatefulWidget {
  const SolicitudesScreen({Key? key}) : super(key: key);

  @override
  State<SolicitudesScreen> createState() => _SolicitudesScreenState();
}

class _SolicitudesScreenState extends State<SolicitudesScreen> {
  final DatabaseReference _database =
      FirebaseDatabase.instance.ref().child('solicitudes');
  String _searchQuery = '';
  String _selectedTurno = 'Turno';
  final List<String> _turnos = ['Turno', 'Mañana', 'Tarde', 'Noche'];
  DateTime? _startDate;
  DateTime? _endDate;
  List<Solicitud>? _cachedSolicitudes;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSolicitudes();
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, now.day);
    _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
  }

  Future<void> _loadSolicitudes() async {
    try {
      final DatabaseEvent event = await _database.once();
      if (mounted) {
        setState(() {
          _cachedSolicitudes = _parseSolicitudes(event.snapshot);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print('Error loading solicitudes: $e');
    }
  }

  List<Solicitud>? _parseSolicitudes(DataSnapshot snapshot) {
    if (snapshot.value == null) return null;

    List<Solicitud> solicitudes = [];
    final data = snapshot.value as Map;

    data.forEach((key, value) {
      if (value is Map) {
        try {
          Map<String, dynamic> solicitudMap = {};
          value.forEach((k, v) {
            solicitudMap[k.toString()] = v;
          });

          if (solicitudMap['materials'] is List) {
            List<Map<String, dynamic>> materialsList = [];
            for (var material in solicitudMap['materials']) {
              if (material is Map) {
                materialsList.add(Map<String, dynamic>.from(material));
              }
            }
            solicitudMap['materials'] = materialsList;
          } else {
            solicitudMap['materials'] = [];
          }

          Solicitud solicitud = Solicitud.fromMap(solicitudMap, key.toString());
          solicitudes.add(solicitud);
        } catch (e) {
          print('Error parsing solicitud: $e');
        }
      }
    });

    return solicitudes;
  }

  DateTime? parseDate(String? dateStr) {
    if (dateStr == null) return null;
    try {
      // Asumiendo formato dd/MM/yyyy
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]), // año
          int.parse(parts[1]), // mes
          int.parse(parts[0]), // día
        );
      }
      return null;
    } catch (e) {
      print('Error parsing date: $e');
      return null;
    }
  }

  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  int _getColumnCount(double width) {
    if (width < 600) return 1;
    if (width < 900) return 2;
    if (width < 1200) return 3;
    return 4;
  }

  double _getAspectRatio(double width) {
    if (width < 600) return 1.0;
    if (width < 900) return 0.8;
    if (width < 1200) return 0.8;
    return 1.1;
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogTheme: DialogTheme(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = DateTime(picked.year, picked.month, picked.day);
        } else {
          _endDate =
              DateTime(picked.year, picked.month, picked.day, 23, 59, 59);
        }
      });
    }
  }

  List<Solicitud> _filterSolicitudes(List<Solicitud> solicitudes) {
    return solicitudes.where((solicitud) {
      bool matchesSearch = solicitud.title
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          solicitud.course.toLowerCase().contains(_searchQuery.toLowerCase());

      bool matchesTurno =
          _selectedTurno == 'Turno' || solicitud.turn == _selectedTurno;

      DateTime? solicitudDate = parseDate(solicitud.date);
      bool matchesDate = true;

      if (solicitudDate != null) {
        if (_startDate != null) {
          matchesDate = matchesDate && !solicitudDate.isBefore(_startDate!);
        }
        if (_endDate != null) {
          matchesDate = matchesDate && !solicitudDate.isAfter(_endDate!);
        }
      }

      return matchesSearch && matchesTurno && matchesDate;
    }).toList();
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: GlobalNavigationBar(),
    drawer: MediaQuery.of(context).size.width < 600
        ? GlobalNavigationBar().buildCustomDrawer(context)
        : null,
    body: RefreshIndicator(
      onRefresh: _loadSolicitudes,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                return constraints.maxWidth < 600
                    ? _buildFiltersColumn()
                    : _buildFiltersRow();
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildSolicitudesList(),
            ),
          ],
        ),
      ),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomeDocente1()),
        );
      },
      tooltip: 'Crear Solicitud',
      child: const Icon(Icons.add),
    ),
  );
}


  Widget _buildSolicitudesList() {
    if (_cachedSolicitudes == null) {
      return const Center(child: Text('No hay solicitudes disponibles'));
    }

    final filteredSolicitudes = _filterSolicitudes(_cachedSolicitudes!);

    if (filteredSolicitudes.isEmpty) {
      return const Center(child: Text('No se encontraron solicitudes'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columnCount = _getColumnCount(constraints.maxWidth);
        final aspectRatio = _getAspectRatio(constraints.maxWidth);

        if (columnCount == 1) {
          return ListView.builder(
            itemCount: filteredSolicitudes.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SolicitudCard(solicitud: filteredSolicitudes[index]),
              );
            },
          );
        } else {
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columnCount,
              childAspectRatio: aspectRatio,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: filteredSolicitudes.length,
            itemBuilder: (context, index) {
              return SolicitudCard(solicitud: filteredSolicitudes[index]);
            },
          );
        }
      },
    );
  }

  Widget _buildFiltersRow() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Buscar por título o curso...',
              prefixIcon: const Icon(Icons.search),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            value: _selectedTurno,
            items: _turnos.map((turno) {
              return DropdownMenuItem(
                value: turno,
                child: Text(turno),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedTurno = value!;
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _selectDate(context, true),
            icon: const Icon(Icons.calendar_today),
            label: Text(_startDate == null ? 'Desde' : formatDate(_startDate!)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _selectDate(context, false),
            icon: const Icon(Icons.calendar_today),
            label: Text(_endDate == null ? 'Hasta' : formatDate(_endDate!)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFiltersColumn() {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'Buscar por título o curso...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          value: _selectedTurno,
          items: _turnos.map((turno) {
            return DropdownMenuItem(
              value: turno,
              child: Text(turno),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedTurno = value!;
            });
          },
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => _selectDate(context, true),
          icon: const Icon(Icons.calendar_today),
          label: Text(_startDate == null ? 'Desde' : formatDate(_startDate!)),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => _selectDate(context, false),
          icon: const Icon(Icons.calendar_today),
          label: Text(_endDate == null ? 'Hasta' : formatDate(_endDate!)),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      ],
    );
  }
}
