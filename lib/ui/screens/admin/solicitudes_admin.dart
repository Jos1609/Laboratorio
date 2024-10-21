import 'package:flutter/material.dart';
import 'package:laboratorio/ui/widgets/navigation_drawer.dart';

class SolicitudesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalNavigationBar(),
      body: Center(
        child: Text(
          'No hay solicitudes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      drawer: GlobalNavigationBar().buildCustomDrawer(context),
    );
  }
}
