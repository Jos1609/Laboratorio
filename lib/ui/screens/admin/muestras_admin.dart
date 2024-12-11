import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laboratorio/data/controllers/muestras_controller.dart';
import 'package:laboratorio/services/muestras_exporter.dart';
import 'package:laboratorio/ui/screens/admin/incidencias_admin_screen.dart';
import 'package:laboratorio/ui/screens/docente/muestras_docente.dart';
import 'package:laboratorio/ui/widgets/navigation_drawer.dart';
import 'package:provider/provider.dart';

class MuestrasAdminScreen extends StatelessWidget {
  const MuestrasAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MuestrasController(),
      child: const MuestrasAdminView(),
    );
  }
}

class MuestrasAdminView extends StatelessWidget {
  const MuestrasAdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GlobalNavigationBar(),
      drawer: MediaQuery.of(context).size.width < 600
          ? const GlobalNavigationBar().buildCustomDrawer(context)
          : null,
      body: AppGradientContainer(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Search and Filter Section
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Search Bar
                      Consumer<MuestrasController>(
                        builder: (context, controller, _) => TextField(
                          onChanged: controller.updateSearchText,
                          decoration: InputDecoration(
                            hintText: 'Buscar muestras...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Date Filter
                      Consumer<MuestrasController>(
                        builder: (context, controller, _) => Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.calendar_today),
                                label: Text(
                                  controller.selectedDateFilter.isEmpty
                                      ? 'Filtrar por fecha'
                                      : 'Fecha: ${controller.selectedDateFilter}',
                                ),
                                onPressed: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2025),
                                  );
                                  if (date != null) {
                                    controller.updateDateFilter(
                                        DateFormat('dd/MM/yyyy').format(date));
                                  }
                                },
                              ),
                            ),
                            if (controller.selectedDateFilter.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: controller.clearDateFilter,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Statistics Card
              Consumer<MuestrasController>(
                builder: (context, controller, child) => Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCard(
                          'Total',
                          controller.filteredMuestras.length.toString(),
                          Colors.blue,
                        ),
                        _buildStatCard(
                          'Pendientes',
                          controller.filteredMuestras
                              .where((m) => m.estado == 'dejado')
                              .length
                              .toString(),
                          Colors.orange,
                        ),
                        _buildStatCard(
                          'Recogidas',
                          controller.filteredMuestras
                              .where((m) => m.estado == 'entregado')
                              .length
                              .toString(),
                          Colors.green,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Muestras List
              Expanded(
                child: Consumer<MuestrasController>(
                  builder: (context, controller, _) {
                    if (controller.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final muestras = controller.filteredMuestras;
                    
                    if (muestras.isEmpty) {
                      return const Center(
                        child: Text('No se encontraron muestras'),
                      );
                    }

                    return ListView.builder(
                      itemCount: muestras.length,
                      itemBuilder: (context, index) {
                        final muestra = muestras[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text(
                              muestra.title,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text('Curso: ${muestra.course}'),
                                Text('Fecha: ${muestra.date ?? "No especificada"}'),
                                Text('Estado: ${muestra.estado}'),
                              ],
                            ),
                            trailing: Chip(
                              label: Text(
                                muestra.estado == 'dejado'
                                    ? 'Pendiente'
                                    : 'Recogido',
                              ),
                              backgroundColor: muestra.estado == 'dejado'
                                  ? Colors.orange.shade100
                                  : Colors.green.shade100,
                              labelStyle: TextStyle(
                                color: muestra.estado == 'dejado'
                                    ? Colors.orange.shade900
                                    : Colors.green.shade900,
                              ),
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
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Botón Exportar
          FloatingActionButton.extended(
            onPressed: () async {
              final controller =
                  Provider.of<MuestrasController>(context, listen: false);
              try {
                await MuestrasExporter.exportMuestras(
                  controller.filteredMuestras,
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
          // Botón Nueva Muestra
          FloatingActionButton.extended(
            onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MuestrasDocente()),
                );
              },
            icon: const Icon(Icons.add),
            label: const Text('Nueva Muestra'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
          style: TextStyle(
            color: color.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}