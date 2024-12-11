import 'package:flutter/material.dart';
import 'package:laboratorio/data/controllers/incidencia_form_controller.dart';
import 'package:laboratorio/data/controllers/incidencias_controller.dart';
import 'package:laboratorio/services/incidencias_exporter.dart';
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
      child: Consumer<IncidenciasController>(
        builder: (context, controller, _) => Scaffold(
          appBar: const GlobalNavigationBar(),
          drawer: MediaQuery.of(context).size.width < 600
              ? const GlobalNavigationBar().buildCustomDrawer(context)
              : null,
          body: const IncidenciasAdminContent(),
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton.extended(
                onPressed: () async {
                  try {
                    await IncidenciasExporter.exportIncidencias(
                      controller.filteredIncidencias
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Archivo exportado correctamente'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al exportar: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.file_download),
                label: const Text('Exportar'),
                backgroundColor: Colors.green,
              ),
              const SizedBox(height: 16),
              FloatingActionButton.extended(
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
            ],
          ),
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