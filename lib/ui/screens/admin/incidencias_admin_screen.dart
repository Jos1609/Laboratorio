// lib/features/incidencias/screens/incidencias_admin_screen.dart

import 'package:flutter/material.dart';
import 'package:laboratorio/data/controllers/incidencia_form_controller.dart';
import 'package:laboratorio/data/controllers/incidencias_controller.dart';
import 'package:laboratorio/ui/widgets/incidencia_form_dialog.dart';
import 'package:laboratorio/ui/widgets/incidencias_admin_content.dart';
import 'package:laboratorio/ui/widgets/navigation_drawer.dart';
import 'package:provider/provider.dart';

class IncidenciasAdminScreen extends StatelessWidget {
  const IncidenciasAdminScreen({super.key});
  

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => IncidenciasController(),
      child: Scaffold(
        appBar: const GlobalNavigationBar(),
        drawer: MediaQuery.of(context).size.width < 600
            ? const GlobalNavigationBar().buildCustomDrawer(context)
            : null,
        body: const IncidenciasAdminContent(),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => showDialog(
            context: context,
            builder: (context) => ChangeNotifierProvider(
              create: (context) => IncidenciaFormController(),
              child: const IncidenciaFormDialog(),
            ),
          ),
          icon: const Icon(Icons.add),
          label: const Text('Nueva Incidencia'),
        ),
      ),
    );
  }
}

class AppGradientContainer extends StatelessWidget {
  final Widget child;

  const AppGradientContainer({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade50, Colors.white],
        ),
      ),
      child: child,
    );
  }
}