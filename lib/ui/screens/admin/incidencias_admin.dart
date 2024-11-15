import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../data/models/incidencia_model.dart';
import '../../../data/repositories/incidencia_repository.dart';
import 'package:intl/intl.dart';
import 'package:laboratorio/ui/widgets/navigation_drawer.dart';

class IncidenciasAdmin extends StatefulWidget {
  const IncidenciasAdmin({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _IncidenciasAdminState createState() => _IncidenciasAdminState();
}

class _IncidenciasAdminState extends State<IncidenciasAdmin> {
  final _formKey = GlobalKey<FormState>();
  final IncidenciaRepository _incidenciaRepository = IncidenciaRepository();

  // Campos del formulario
  String _nombrePractica = '';
  String _lugar = '';
  String _observador = '';
  String _curso = '';
  String _incidente = '';
  String _tratamiento = '';
  String _derivacion = '';
  String _compromiso = '';
  String _estado = 'Pendiente';
  DateTime _fecha = DateTime.now();
  String _searchText = '';
  String _selectedDateFilter = '';
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalNavigationBar(),
      drawer: MediaQuery.of(context).size.width < 600
          ? GlobalNavigationBar().buildCustomDrawer(context)
          : null,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: Column(
          children: [
            // Header Section with Stats
            Container(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: StreamBuilder(
                    stream: _incidenciaRepository.getIncidenciasStream(),
                    builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                      int totalIncidencias = 0;
                      int pendientes = 0;
                      if (snapshot.hasData &&
                          snapshot.data!.snapshot.value != null) {
                        Map<dynamic, dynamic> incidencias = snapshot
                            .data!.snapshot.value as Map<dynamic, dynamic>;
                        totalIncidencias = incidencias.length;
                        pendientes = incidencias.values
                            .where((inc) => inc['estado'] == 'Pendiente')
                            .length;
                      }
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatCard(
                            'Total Incidencias',
                            totalIncidencias.toString(),
                            Icons.list_alt,
                            Colors.blue,
                          ),
                          _buildStatCard(
                            'Pendientes',
                            pendientes.toString(),
                            Icons.pending_actions,
                            Colors.orange,
                          ),
                          _buildStatCard(
                            'Devueltas',
                            (totalIncidencias - pendientes).toString(),
                            Icons.check_circle_outline,
                            Colors.green,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            // Search and Filter Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Buscar incidencias...',
                            prefixIcon: Icon(Icons.search),
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchText = value;
                            });
                          },
                        ),
                      ),
                      IconButton(
                        tooltip: 'Filtrar por fecha',
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _showDateFilterDialog(),
                      ),
                      if (_selectedDateFilter.isNotEmpty)
                        IconButton(
                          tooltip: 'Limpiar filtro de fecha',
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _selectedDateFilter = '';
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
            // Lista de Incidencias
            Expanded(
              child: StreamBuilder(
                stream: _incidenciaRepository.getIncidenciasStream(),
                builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData ||
                      snapshot.data!.snapshot.value == null) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_outlined,
                              size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No hay incidencias registradas',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  Map<dynamic, dynamic> incidencias =
                      snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

                  // Filtrar incidencias
                  var filteredIncidencias = Map.fromEntries(
                    incidencias.entries.where((entry) {
                      final incidencia = entry.value as Map;
                      bool matchesSearch = incidencia['nombrePractica']
                              .toString()
                              .toLowerCase()
                              .contains(_searchText.toLowerCase()) ||
                          incidencia['curso']
                              .toString()
                              .toLowerCase()
                              .contains(_searchText.toLowerCase());
                      bool matchesDate = _selectedDateFilter.isEmpty ||
                          incidencia['fecha']
                              .toString()
                              .startsWith(_selectedDateFilter);
                      return matchesSearch && matchesDate;
                    }),
                  );

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredIncidencias.length,
                    itemBuilder: (context, index) {
                      String key = filteredIncidencias.keys.elementAt(index);
                      Map incidencia = filteredIncidencias[key];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: incidencia['estado'] == 'Pendiente'
                                ? Colors.orange
                                : Colors.green,
                            child: Icon(
                              incidencia['estado'] == 'Pendiente'
                                  ? Icons.pending_actions
                                  : Icons.check_circle_outline,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            incidencia['nombrePractica'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Curso: ${incidencia['curso']}'),
                              Text(
                                'Fecha: ${incidencia['fecha']}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _showIncidenciaDetail(incidencia, key),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFormDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Nueva Incidencia'),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  void _showFormDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.note_add, color: Colors.blue.shade700),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Registrar Nueva Incidencia',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Form
                Expanded(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Sección de Información Básica
                          _buildSectionHeader(
                              'Información Básica', Icons.info_outline),
                          _buildTextField(
                            'Nombre de la Práctica',
                            Icons.science,
                            onSaved: (value) => _nombrePractica = value ?? '',
                            validator: (value) =>
                                value!.isEmpty ? 'Campo requerido' : null,
                            required: true,
                          ),
                          _buildTextField(
                            'Lugar',
                            Icons.location_on,
                            onSaved: (value) => _lugar = value ?? '',
                          ),
                          _buildTextField(
                            'Curso',
                            Icons.school,
                            onSaved: (value) => _curso = value ?? '',
                          ),

                          const SizedBox(height: 20),

                          // Sección de Detalles del Incidente
                          _buildSectionHeader(
                              'Detalles del Incidente', Icons.warning_amber),
                          _buildTextField(
                            'Observador',
                            Icons.person,
                            onSaved: (value) => _observador = value ?? '',
                          ),
                          _buildTextField(
                            'Incidente',
                            Icons.report_problem,
                            onSaved: (value) => _incidente = value ?? '',
                            maxLines: 3,
                            helperText:
                                'Describe detalladamente el incidente ocurrido',
                          ),

                          const SizedBox(height: 20),

                          // Sección de Seguimiento
                          _buildSectionHeader('Seguimiento', Icons.timeline),
                          _buildTextField(
                            'Tratamiento',
                            Icons.healing,
                            onSaved: (value) => _tratamiento = value ?? '',
                            maxLines: 2,
                          ),
                          _buildTextField(
                            'Derivación',
                            Icons.alt_route,
                            onSaved: (value) => _derivacion = value ?? '',
                          ),
                          _buildTextField(
                            'Compromiso',
                            Icons.handshake,
                            onSaved: (value) => _compromiso = value ?? '',
                            maxLines: 2,
                          ),

                          const SizedBox(height: 20),

                          // Sección de Estado y Fecha
                          _buildSectionHeader(
                              'Estado y Fecha', Icons.date_range),
                          _buildDateTimeField(),
                          _buildStatusDropdown(),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.close),
                      label: const Text('Cancelar'),
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('Guardar Incidencia'),
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    IconData icon, {
    Function(String?)? onSaved,
    String? Function(String?)? validator,
    int maxLines = 1,
    String? helperText,
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        onSaved: onSaved,
        validator: validator,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label + (required ? ' *' : ''),
          helperText: helperText,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
    );
  }

  Widget _buildDateTimeField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: TextEditingController(
          text: DateFormat('yyyy-MM-dd HH:mm').format(_fecha),
        ),
        decoration: InputDecoration(
          labelText: 'Fecha y Hora',
          prefixIcon: const Icon(Icons.calendar_today),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        readOnly: true,
        onTap: () async {
          FocusScope.of(context).requestFocus(FocusNode());
          DateTime? selectedDate = await showDatePicker(
            context: context,
            initialDate: _fecha,
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Colors.blue,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black,
                  ),
                ),
                child: child!,
              );
            },
          );
          if (selectedDate != null) {
            TimeOfDay? selectedTime = await showTimePicker(
              // ignore: use_build_context_synchronously
              context: context,
              initialTime: TimeOfDay.fromDateTime(_fecha),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Colors.blue,
                      surface: Colors.white,
                      onSurface: Colors.black,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (selectedTime != null) {
              setState(() {
                _fecha = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  selectedTime.hour,
                  selectedTime.minute,
                );
              });
            }
          }
        },
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Estado',
          prefixIcon: const Icon(Icons.flag),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        value: _estado,
        items: ['Pendiente', 'Devuelto'].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (value) => setState(() => _estado = value ?? 'Pendiente'),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Incidencia nuevaIncidencia = Incidencia(
        nombrePractica: _nombrePractica,
        lugar: _lugar,
        observador: _observador,
        curso: _curso,
        incidente: _incidente,
        tratamiento: _tratamiento,
        derivacion: _derivacion,
        compromiso: _compromiso,
        estado: _estado,
        fecha:
            DateFormat('yyyy-MM-dd HH:mm').format(_fecha), // Guardamos la fecha
      );
      _incidenciaRepository.addIncidencia(nuevaIncidencia).then((_) {
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incidencia registrada exitosamente')),
        );
      }).catchError((error) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar la incidencia: $error')),
        );
      });
    }
  }

  void _showDateFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filtrar por Fecha'),
          content: TextField(
            decoration: const InputDecoration(labelText: 'Fecha (yyyy-mm-dd)'),
            onChanged: (value) {
              setState(() {
                _selectedDateFilter = value;
              });
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  void _showIncidenciaDetail(Map incidencia, String key) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                incidencia['estado'] == 'Pendiente'
                    ? Icons.pending_actions
                    : Icons.check_circle_outline,
                color: incidencia['estado'] == 'Pendiente'
                    ? Colors.orange
                    : Colors.green,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  incidencia['nombrePractica'],
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailItem(
                    'Lugar', incidencia['lugar'], Icons.location_on),
                _buildDetailItem(
                    'Observador', incidencia['observador'], Icons.person),
                _buildDetailItem('Curso', incidencia['curso'], Icons.school),
                _buildDetailItem(
                    'Incidente', incidencia['incidente'], Icons.warning),
                _buildDetailItem(
                    'Tratamiento', incidencia['tratamiento'], Icons.healing),
                _buildDetailItem(
                    'Derivación', incidencia['derivacion'], Icons.merge_type),
                _buildDetailItem(
                    'Compromiso', incidencia['compromiso'], Icons.handshake),
                _buildDetailItem(
                    'Fecha', incidencia['fecha'], Icons.calendar_today),
                _buildDetailItem(
                    'Estado', incidencia['estado'], Icons.info_outline),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
            if (incidencia['estado'] == 'Pendiente')
              ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label: const Text('Marcar como Devuelto'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                onPressed: () {
                  _incidenciaRepository
                      .updateIncidenciaStatus(key, 'Devuelto')
                      .then((_) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Estado actualizado a Devuelto'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al actualizar el estado: $error'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  });
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
