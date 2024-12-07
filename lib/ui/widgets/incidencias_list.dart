// lib/features/incidencias/widgets/incidencias_list.dart

import 'package:flutter/material.dart';
import 'package:laboratorio/data/controllers/incidencias_controller.dart';
import 'package:provider/provider.dart';
import '../../../data/models/incidencia_model.dart';
import 'incidencia_detail_dialog.dart';

class IncidenciasList extends StatelessWidget {
 const IncidenciasList({super.key});

 @override
 Widget build(BuildContext context) {
   final controller = context.watch<IncidenciasController>();

    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final incidencias = controller.filteredIncidencias;
    
    if (incidencias.isEmpty) {
      return const _EmptyState();
    }

    return ListView.builder(
      itemCount: incidencias.length,
      itemBuilder: (context, index) {
        final incidencia = incidencias[index];
        return _IncidenciaCard(incidencia: incidencia);
      },
    );
 }
}

class _IncidenciaCard extends StatelessWidget {
 final Incidencia incidencia;

 const _IncidenciaCard({required this.incidencia});

 @override
 Widget build(BuildContext context) {
   final isPendiente = incidencia.estado == 'Pendiente';

   return Card(
     margin: const EdgeInsets.symmetric(vertical: 4),
     child: ListTile(
       leading: CircleAvatar(
         backgroundColor: isPendiente ? Colors.orange : Colors.green,
         child: Icon(
           isPendiente ? Icons.pending_actions : Icons.check_circle_outline,
           color: Colors.white,
         ),
       ),
       title: Text(
         incidencia.nombrePractica,
         style: const TextStyle(fontWeight: FontWeight.bold),
       ),
       subtitle: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Text('Curso: ${incidencia.curso}'),
           Text(
             'Fecha: ${incidencia.fecha}',
             style: const TextStyle(fontSize: 12),
           ),
         ],
       ),
       trailing: const Icon(Icons.chevron_right),
       onTap: () => showDialog(
         context: context,
         builder: (context) => IncidenciaDetailDialog(incidencia: incidencia),
       ),
     ),
   );
 }
}

class _EmptyState extends StatelessWidget {
 const _EmptyState();

 @override
 Widget build(BuildContext context) {
   return const Center(
     child: Column(
       mainAxisAlignment: MainAxisAlignment.center,
       children: [
         Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
         SizedBox(height: 16),
         Text(
           'No hay incidencias registradas',
           style: TextStyle(fontSize: 18, color: Colors.grey),
         ),
       ],
     ),
   );
 }
}