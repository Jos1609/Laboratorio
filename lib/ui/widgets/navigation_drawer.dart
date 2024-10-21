import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GlobalNavigationBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return AppBar(
      title: Text('Laboratorio'),
      backgroundColor: Colors.blue,
      actions: [
        if (!isSmallScreen) ..._buildNavigationActions(context),
      ],
      leading: isSmallScreen
          ? Builder(
              builder: (context) => IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            )
          : null,
    );
  }

  List<Widget> _buildNavigationActions(BuildContext context) {
    return [
      _buildNavButton(context, 'Materiales', '/materiales'),
      _buildNavButton(context, 'Solicitudes', '/solicitudes'),
      _buildNavButton(context, 'Incidencias', '/incidencias'),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: ElevatedButton(
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.of(context).pushReplacementNamed('/');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red, // Color de fondo rojo
            padding: const EdgeInsets.symmetric(vertical: 16), // Espaciado vertical
          ),
          child: const Text(
            'Cerrar Sesión',
            style: TextStyle(
              color: Colors.white, // Texto en blanco
              fontSize: 16, // Tamaño de fuente
              fontWeight: FontWeight.bold, // Negrita
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildNavButton(BuildContext context, String label, String route) {
    return TextButton(
      onPressed: () {
        Navigator.of(context).pushNamed(route);
      },
      child: Text(label, style: TextStyle(color: Colors.white)),
    );
  }

  Widget buildCustomDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Menú de navegación',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          _buildDrawerItem(context, 'Materiales', '/materiales'),
          _buildDrawerItem(context, 'Solicitudes', '/solicitudes'),
          _buildDrawerItem(context, 'Incidencias', '/incidencias'),
          ListTile(
            title: ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacementNamed('/');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Cerrar Sesión',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, String label, String route) {
    return ListTile(
      title: Text(label),
      onTap: () {
        Navigator.of(context).pushNamed(route);
      },
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
