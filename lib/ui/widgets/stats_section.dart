import 'package:flutter/material.dart';
import 'package:laboratorio/data/controllers/incidencias_controller.dart';
import 'package:provider/provider.dart';
class StatsSection extends StatelessWidget {
 const StatsSection({super.key});

 @override
 Widget build(BuildContext context) {
   final controller = context.watch<IncidenciasController>();

   return Card(
     elevation: 4,
     child: Padding(
       padding: const EdgeInsets.all(16),
       child: StreamBuilder(
         stream: controller.incidenciasStream,
         builder: (context, snapshot) {
           if (!snapshot.hasData) {
             return const Center(child: CircularProgressIndicator());
           }

           final incidencias = controller.filteredIncidencias;
           final stats = controller.calculateStats(incidencias);

           return Row(
             mainAxisAlignment: MainAxisAlignment.spaceAround,
             children: [
               _StatCard(
                 title: 'Total Incidencias',
                 value: stats['total'].toString(),
                 icon: Icons.list_alt,
                 color: Colors.blue,
                 onTap: () => controller.updateFilter('todas'),
                 isSelected: controller.currentFilter == 'todas',
               ),
               _StatCard(
                 title: 'Pendientes',
                 value: stats['pendientes'].toString(),
                 icon: Icons.pending_actions,
                 color: Colors.orange,
                 onTap: () => controller.updateFilter('pendientes'),
                 isSelected: controller.currentFilter == 'pendientes',
               ),
               _StatCard(
                 title: 'Devueltas',
                 value: stats['devueltas'].toString(),
                 icon: Icons.check_circle_outline,
                 color: Colors.green,
                 onTap: () => controller.updateFilter('devueltas'),
                 isSelected: controller.currentFilter == 'devueltas',
               ),
             ],
           );
         },
       ),
     ),
   );
 }
}

class _StatCard extends StatelessWidget {
 final String title;
 final String value;
 final IconData icon;
 final Color color;
 final VoidCallback onTap;
 final bool isSelected;

 const _StatCard({
   required this.title,
   required this.value,
   required this.icon,
   required this.color,
   required this.onTap,
   required this.isSelected,
 });

 @override
 Widget build(BuildContext context) {
   return InkWell(
     onTap: onTap,
     borderRadius: BorderRadius.circular(8),
     child: Container(
       padding: const EdgeInsets.all(8),
       decoration: BoxDecoration(
         borderRadius: BorderRadius.circular(8),
         border: Border.all(
           color: isSelected ? color : Colors.transparent,
           width: 2,
         ),
       ),
       child: Column(
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
       ),
     ),
   );
 }
}