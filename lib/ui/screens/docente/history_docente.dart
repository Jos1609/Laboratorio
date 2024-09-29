import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:laboratorio/core/constants/app_colors.dart';
import 'package:laboratorio/data/models/muestra.dart';
import 'package:laboratorio/services/auth_service.dart';
import 'package:laboratorio/services/muestra_service.dart';
import 'package:laboratorio/ui/screens/login/login_screen.dart';
import 'package:laboratorio/ui/screens/login/login_viewmodel.dart';
import 'package:laboratorio/ui/widgets/custom_navigation_bar.dart';
import 'package:provider/provider.dart';

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
      // Si no está autenticado, redirige a la pantalla de inicio de sesión
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  Future<void> _testFirebaseConnection() async {
    try {
      DatabaseEvent event = await FirebaseDatabase.instance.ref('muestras').limitToFirst(1).once();
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
          title: const Text('¿Has retirado todas las muestras del laboratorio?'),
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
    ) ?? false;
  }

  void _confirmarRetiro(String muestraKey) async {
  bool confirmed = await _showConfirmationDialog(context);
  if (confirmed) {
    // Obtener la fecha actual en el formato deseado (dd/MM/yyyy)
    String fechaActual = DateFormat('dd/MM/yyyy').format(DateTime.now());

    // Llamar al método de actualización con la fecha actual
    await _muestraService.updateMuestraEstado(muestraKey, 'entregado', fechaActual); 
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de muestras'),
        backgroundColor: AppColors.mainColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Llamar al método signOut del LoginViewModel
              final loginViewModel =
                  Provider.of<LoginViewModel>(context, listen: false);
              loginViewModel.signOut(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtro con barra similar a la imagen enviada
          Container(
            margin: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _filter == 'dejado' ? Colors.blue : Colors.grey,
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
                    backgroundColor: _filter == 'entregado' ? Colors.blue : Colors.grey,
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
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
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

                Map<dynamic, dynamic> muestrasMap = Map<dynamic, dynamic>.from(snapshot.data!.snapshot.value as Map);
                List<Muestra> muestras = muestrasMap.entries
                    .map((e) => Muestra.fromMap(Map<String, dynamic>.from(e.value), e.key))
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
                              ? null  // Botón desactivado si la muestra está recogida
                              : () {
                                  if (muestra.key != null) {
                                    _confirmarRetiro(muestra.key!);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('No se puede confirmar la muestra sin clave.')),
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
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomNavigationBar(),
    );
  }
}
