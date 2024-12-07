import 'package:flutter/material.dart';
import 'package:laboratorio/data/controllers/incidencias_controller.dart';
import 'package:provider/provider.dart';

class SearchFilterSection extends StatelessWidget {
  const SearchFilterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<IncidenciasController>();

    return Card(
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
                onChanged: controller.updateSearchText,
              ),
            ),
            IconButton(
              tooltip: 'Filtrar por fecha',
              icon: const Icon(Icons.calendar_today),
              onPressed: () => _showDateFilterDialog(context),
            ),
            if (controller.selectedDateFilter.isNotEmpty)
              IconButton(
                tooltip: 'Limpiar filtro de fecha',
                icon: const Icon(Icons.clear),
                onPressed: () => controller.clearDateFilter(),
              ),
          ],
        ),
      ),
    );
  }

  void _showDateFilterDialog(BuildContext context) {
    final controller = context.read<IncidenciasController>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filtrar por Fecha'),
          content: SizedBox(
            height: 250,
            width: 300,
            child: CalendarDatePicker(
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
              onDateChanged: (date) {
                controller.updateDateFilter(
                    date.toString().split(' ')[0] // Formato yyyy-mm-dd
                    );
                Navigator.pop(context);
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }
}
