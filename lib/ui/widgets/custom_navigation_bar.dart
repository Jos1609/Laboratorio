import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:laboratorio/data/models/navigation_model.dart';

class CustomNavigationBar extends StatelessWidget {
  const CustomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationModel>(
      builder: (context, navigationModel, child) {
        return BottomNavigationBar(
          currentIndex: navigationModel.currentIndex,
          onTap: (index) {
            navigationModel.setIndex(index);

            // Dependiendo del índice, navega a la pantalla correspondiente.
            switch (index) {
              case 0:
                Navigator.pushReplacementNamed(context, '/home-docente');
                break;
              case 1:
                Navigator.pushReplacementNamed(context, '/history');
                break;
              case 2:
                Navigator.pushReplacementNamed(context, '/muestras');
                break;
              case 3:
                Navigator.pushReplacementNamed(context, '/profile');
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historial'),
            BottomNavigationBarItem(icon: Icon(Icons.science), label: 'Muestras'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          ],
        );
      },
    );
  }
}
