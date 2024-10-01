import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:laboratorio/core/constants/app_colors.dart';
import 'package:laboratorio/data/models/muestra.dart';
import 'package:laboratorio/data/models/solicitud_model.dart';
import 'package:laboratorio/services/auth_service.dart';
import 'package:laboratorio/services/muestra_service.dart';
import 'package:laboratorio/ui/screens/login/login_screen.dart';
import 'package:laboratorio/ui/screens/login/login_viewmodel.dart';
import 'package:laboratorio/ui/widgets/custom_navigation_bar.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

class HistoryDocente extends StatefulWidget {
  const HistoryDocente({super.key});

  @override
  _HistoryDocenteState createState() => _HistoryDocenteState();
}

class _HistoryDocenteState extends State<HistoryDocente> {
  final MuestraService _muestraService = MuestraService();
  String _filter = 'dejado';
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _testFirebaseConnection();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    bool isAuthenticated = await _authService.isUserAuthenticated();
    if (!isAuthenticated) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  Future<void> _testFirebaseConnection() async {
    try {
      DatabaseEvent event = await FirebaseDatabase.instance
          .ref('muestras')
          .limitToFirst(1)
          .once();
      print('Test query result: ${event.snapshot.value}');
    } catch (e) {
      print('Error en test query: $e');
    }
  }

  Future<bool> _showConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(
                  '¿Has retirado todas las muestras del laboratorio?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Sí'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('No'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _confirmarRetiro(String muestraKey) async {
    bool confirmed = await _showConfirmationDialog(context);
    if (confirmed) {
      String fechaActual = DateFormat('dd/MM/yyyy').format(DateTime.now());
      await _muestraService.updateMuestraEstado(
          muestraKey, 'entregado', fechaActual);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de muestras y solicitudes'),
        backgroundColor: AppColors.mainColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              final loginViewModel =
                  Provider.of<LoginViewModel>(context, listen: false);
              loginViewModel.signOut(context);
            },
          ),
        ],
      ),
      body: DefaultTabController(
        length: 2, // Una pestaña para Muestras y otra para Solicitudes
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Muestras'),
                Tab(text: 'Solicitudes'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Vista de Muestras
                  Column(
                    children: [
                      Expanded(child: _buildMuestrasList()),
                      Container(
                        margin: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _filter == 'dejado'
                                    ? Colors.blue
                                    : Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _filter = 'dejado';
                                });
                              },
                              child: const Text('Pendientes'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _filter == 'entregado'
                                    ? Colors.blue
                                    : Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _filter = 'entregado';
                                });
                              },
                              child: const Text('Recogidas'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Vista de Solicitudes
                  _buildSolicitudesList(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomNavigationBar(),
    );
  }

  // Método para mostrar la lista de muestras
  Widget _buildMuestrasList() {
    return StreamBuilder<DatabaseEvent>(
      stream: _muestraService.getMuestrasStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return const Center(child: Text('No hay muestras disponibles'));
        }

        Map<dynamic, dynamic> muestrasMap =
            snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

        List<Muestra> muestras = muestrasMap.entries
            .map((entry) {
              final muestraKey = entry.key;
              final muestraValue =
                  Map<String, dynamic>.from(entry.value as Map);
              return Muestra.fromMap(muestraValue, muestraKey);
            })
            .where((muestra) => muestra.estado == _filter)
            .toList();

        return ListView.builder(
          itemCount: muestras.length,
          itemBuilder: (context, index) {
            Muestra muestra = muestras[index];
            return Card(
              margin: const EdgeInsets.all(10),
              child: ListTile(
                title: Text('Título: ${muestra.title}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Fecha Dejado: ${muestra.date ?? 'No especificada'}'),
                    Text('Curso: ${muestra.course}'),
                  ],
                ),
                trailing: ElevatedButton(
                  onPressed: muestra.estado == 'entregado'
                      ? null
                      : () {
                          if (muestra.key != null) {
                            _confirmarRetiro(muestra.key!);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'No se puede confirmar la muestra sin clave.')),
                            );
                          }
                        },
                  child: const Text('Confirmar'),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSolicitudesList() {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Center(child: Text('Usuario no autenticado'));
    }

    return StreamBuilder<DatabaseEvent>(
      stream: FirebaseDatabase.instance.ref('solicitudes').onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return const Center(child: Text('No hay solicitudes disponibles'));
        }

        List<Solicitud> solicitudes = [];
        final data = snapshot.data!.snapshot.value;

        // Usamos ahora la fecha y hora exacta, no solo el día
        final now = DateTime.now();

        if (data is Map) {
          data.forEach((key, value) {
            try {
              if (value is Map<Object?, Object?>) {
                String jsonString = jsonEncode(value);
                Map<String, dynamic> solicitudMap = jsonDecode(jsonString);

                Solicitud solicitud =
                    Solicitud.fromMap(solicitudMap, key.toString());

                // Filtrar por usuario autenticado
                if (solicitud.userId == currentUser.uid) {
                  // Verificar si la fecha es actual o futura, restando un día a la fecha de la solicitud
                  DateTime? solicitudDate = parseDate(solicitud.date ?? '');

                  // Restar un día a la fecha actual (now)
                  DateTime adjustedNow = now.subtract(const Duration(days: 1));

                  if (solicitudDate != null &&
                      (solicitudDate.isAfter(adjustedNow) ||
                          solicitudDate.isAtSameMomentAs(adjustedNow))) {
                    solicitudes.add(solicitud);
                  }
                }
              }
            } catch (e) {
              print('Error al procesar solicitud $key: $e');
            }
          });
        }

        if (solicitudes.isEmpty) {
          return const Center(
              child: Text('No tienes solicitudes actuales o futuras'));
        }

        solicitudes.sort((a, b) {
          DateTime? dateA = parseDate(a.date ?? '');
          DateTime? dateB = parseDate(b.date ?? '');
          if (dateA == null || dateB == null) return 0;
          return dateA.compareTo(dateB);
        });

        return ListView.builder(
          itemCount: solicitudes.length,
          itemBuilder: (context, index) {
            Solicitud solicitud = solicitudes[index];
            return Card(
              margin: const EdgeInsets.all(10),
              child: ListTile(
                title: Text('Título: ${solicitud.title}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Curso: ${solicitud.course}'),
                    Text('Cantidad de estudiantes: ${solicitud.studentCount}'),
                    Text('Turno: ${solicitud.turn}'),
                    Text('Fecha: ${solicitud.date ?? 'No especificada'}'),
                    Text(
                        'Hora Inicio: ${solicitud.startTime ?? 'No especificada'}'),
                    Text('Hora Fin: ${solicitud.endTime ?? 'No especificada'}'),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  DateTime? parseDate(String date) {
    try {
      // Intentar parsear el formato DD/MM/YYYY
      List<String> parts = date.split('/');
      if (parts.length == 3) {
        int day = int.parse(parts[0]);
        int month = int.parse(parts[1]);
        int year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (e) {
      print('Error parsing date: $date');
    }

    // Si falla, intentar el formato ISO
    try {
      return DateTime.parse(date);
    } catch (e) {
      print('Error parsing ISO date: $date');
    }

    return null;
  }
}
