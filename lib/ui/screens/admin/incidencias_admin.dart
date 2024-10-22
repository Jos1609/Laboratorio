import 'package:flutter/material.dart';
import 'package:laboratorio/ui/widgets/navigation_drawer.dart';

class IncidenciasScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalNavigationBar(),
      body: Center(
        child: Text(
          'No hay incidencias',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      drawer: MediaQuery.of(context).size.width < 600
          ? GlobalNavigationBar().buildCustomDrawer(context)
          : null, // Si es pantalla grande, no mostrar el Drawer
    );
  }
}
