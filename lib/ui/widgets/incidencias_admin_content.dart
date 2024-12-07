import 'package:flutter/material.dart';
import '../widgets/stats_section.dart';
import '../widgets/search_filter_section.dart';
import '../widgets/incidencias_list.dart';

class IncidenciasAdminContent extends StatelessWidget {
 const IncidenciasAdminContent({super.key});

 @override
 Widget build(BuildContext context) {
   return const AppGradientContainer(
     child: Padding(
       padding: EdgeInsets.all(16.0),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.stretch,
         children: [
           StatsSection(),
           SizedBox(height: 16),
           SearchFilterSection(),
           SizedBox(height: 16),
           Expanded(
             child: IncidenciasList(),
           ),
         ],
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