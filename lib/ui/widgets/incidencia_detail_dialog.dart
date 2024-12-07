import 'package:flutter/material.dart';
import 'package:laboratorio/data/controllers/incidencias_controller.dart';
import 'package:provider/provider.dart';
import '../../../data/models/incidencia_model.dart';

class IncidenciaDetailDialog extends StatelessWidget {
 final Incidencia incidencia;

 const IncidenciaDetailDialog({
   super.key,
   required this.incidencia,
 });

 @override
 Widget build(BuildContext context) {
   final controller = context.read<IncidenciasController>();
   final isPendiente = incidencia.estado == 'Pendiente';

   return AlertDialog(
     title: Row(
       children: [
         Icon(
           isPendiente ? Icons.pending_actions : Icons.check_circle_outline,
           color: isPendiente ? Colors.orange : Colors.green,
         ),
         const SizedBox(width: 8),
         Expanded(
           child: Text(
             incidencia.nombrePractica,
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
           _DetailItem(label: 'Lugar', value: incidencia.lugar, icon: Icons.location_on),
           _DetailItem(label: 'Observador', value: incidencia.observador, icon: Icons.person),
           _DetailItem(label: 'Curso', value: incidencia.curso, icon: Icons.school),
           _DetailItem(label: 'Incidente', value: incidencia.incidente, icon: Icons.warning),
           _DetailItem(label: 'Tratamiento', value: incidencia.tratamiento, icon: Icons.healing),
           _DetailItem(label: 'Derivación', value: incidencia.derivacion, icon: Icons.merge_type),
           _DetailItem(label: 'Compromiso', value: incidencia.compromiso, icon: Icons.handshake),
           _DetailItem(label: 'Fecha', value: incidencia.fecha, icon: Icons.calendar_today),
           _DetailItem(label: 'Estado', value: incidencia.estado, icon: Icons.info_outline),
         ],
       ),
     ),
     actions: [
       TextButton(
         onPressed: () => Navigator.pop(context),
         child: const Text('Cerrar'),
       ),
       if (isPendiente)
         ElevatedButton.icon(
           icon: const Icon(Icons.check),
           label: const Text('Marcar como Devuelto'),
           style: ElevatedButton.styleFrom(
             backgroundColor: Colors.green,
             foregroundColor: Colors.white,
           ),
           onPressed: () async {
             try {
               await controller.updateIncidenciaStatus(incidencia.id!, 'Devuelto');
               // ignore: use_build_context_synchronously
               Navigator.pop(context);
               // ignore: use_build_context_synchronously
               ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(
                   content: Text('Estado actualizado a Devuelto'),
                   backgroundColor: Colors.green,
                 ),
               );
             } catch (e) {
               ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(
                   content: Text(e.toString()),
                   backgroundColor: Colors.red,
                 ),
               );
             }
           },
         ),
     ],
   );
 }
}

class _DetailItem extends StatelessWidget {
 final String label;
 final String value;
 final IconData icon;

 const _DetailItem({
   required this.label,
   required this.value,
   required this.icon,
 });

 @override
 Widget build(BuildContext context) {
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