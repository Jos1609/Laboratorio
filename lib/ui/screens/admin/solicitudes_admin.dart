// lib/screens/solicitudes_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../data/models/solicitud_model.dart';
import 'package:laboratorio/ui/widgets/navigation_drawer.dart';

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

// Función para determinar el número de columnas según el ancho de la pantalla
  int _getColumnCount(double width) {
    if (width < 600) return 1; // Móviles
    if (width < 900) return 2; // Tablets pequeñas
    if (width < 1200) return 3; // Tablets grandes / pantallas pequeñas
    return 4; // Pantallas grandes
  }

// Función para ajustar el childAspectRatio según el ancho de la pantalla
  double _getAspectRatio(double width) {
    if (width < 600) return 1.0; // Móviles: Relación de aspecto cuadrada
    if (width < 900) return 0.8; // Tablets pequeñas: Un poco más de altura
    if (width < 1200) return 0.8; // Tablets grandes: Mantén las tarjetas cuadradas
    return 1.1; // Pantallas grandes: Relación más ancha
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalNavigationBar(),
      drawer: MediaQuery.of(context).size.width < 600
          ? GlobalNavigationBar().buildCustomDrawer(context)
          : null, // Si es pantalla grande, no mostrar el Drawer
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Filtros en una fila para pantallas grandes o columna para móviles
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  return _buildFiltersColumn();
                } else {
                  return _buildFiltersRow();
                }
              },
            ),
            const SizedBox(height: 16),
            // Lista de solicitudes
            Expanded(
              child: StreamBuilder(
                stream: _database.onValue,
                builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Error al cargar las solicitudes'),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData ||
                      snapshot.data!.snapshot.value == null) {
                    return const Center(
                      child: Text('No hay solicitudes disponibles'),
                    );
                  }

                  List<Solicitud> solicitudes = [];
                  final data = snapshot.data!.snapshot.value;
                  if (data is Map) {
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
                                materialsList
                                    .add(Map<String, dynamic>.from(material));
                              }
                            }
                            solicitudMap['materials'] = materialsList;
                          } else {
                            solicitudMap['materials'] = [];
                          }

                          Solicitud solicitud =
                              Solicitud.fromMap(solicitudMap, key.toString());
                          solicitudes.add(solicitud);
                        } catch (e) {
                          print('Error al convertir solicitud: $e');
                        }
                      }
                    });
                  }

                  List<Solicitud> filteredSolicitudes =
                      solicitudes.where((solicitud) {
                    bool matchesSearch = solicitud.title
                            .toLowerCase()
                            .contains(_searchQuery) ||
                        solicitud.course.toLowerCase().contains(_searchQuery);
                    bool matchesTurno = _selectedTurno == 'Turno' ||
                        solicitud.turn == _selectedTurno;
                    return matchesSearch && matchesTurno;
                  }).toList();

                  if (filteredSolicitudes.isEmpty) {
                    return const Center(
                      child: Text('No se encontraron solicitudes'),
                    );
                  }

                  // Diseño responsivo usando LayoutBuilder
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final columnCount = _getColumnCount(constraints.maxWidth);
                      final aspectRatio = _getAspectRatio(constraints.maxWidth);

                      if (columnCount == 1) {
                        // Vista de lista para móviles
                        return ListView.builder(
                          itemCount: filteredSolicitudes.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: SolicitudCard(
                                  solicitud: filteredSolicitudes[index]),
                            );
                          },
                        );
                      } else {
                        // Grid view para tablets y desktop
                        return GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columnCount,
                            childAspectRatio:
                                aspectRatio, // Ajuste del childAspectRatio
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: filteredSolicitudes.length,
                          itemBuilder: (context, index) {
                            return SolicitudCard(
                                solicitud: filteredSolicitudes[index]);
                          },
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
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
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value.toLowerCase();
            });
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
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
      ],
    );
  }
}

class SolicitudCard extends StatelessWidget {
  final Solicitud solicitud;

  const SolicitudCard({
    Key? key,
    required this.solicitud,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        title: Text(
          solicitud.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    solicitud.date ?? 'Sin fecha',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${solicitud.startTime ?? 'N/A'} - ${solicitud.endTime ?? 'N/A'}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight:
                  200, // Limitar la altura máxima del contenido expandido
            ),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Curso', solicitud.course),
                  _buildInfoRow('Estudiantes', solicitud.studentCount),
                  _buildInfoRow('Turno', solicitud.turn),
                  const SizedBox(height: 12),
                  const Text(
                    'Materiales requeridos:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...solicitud.materials.map((material) => Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 4),
                        child: Text(
                            '• ${material.name} - ${material.quantity} unidades'),
                      )),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
