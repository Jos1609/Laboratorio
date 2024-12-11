import 'package:flutter/material.dart';

class GlobalNavigationBar extends StatelessWidget implements PreferredSizeWidget {
  const GlobalNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return AppBar(
      title: const Text('Laboratorio'),
      backgroundColor: Colors.blue,
      actions: [
        if (!isSmallScreen) ..._buildNavigationActions(context),
      ],
      leading: isSmallScreen
          ? Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
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
      _buildNavButton(context, 'Materiales', '/home-admin'),
      _buildNavButton(context, 'Solicitudes', '/solicitudes'),
      _buildNavButton(context, 'Incidencias', '/incidencias'),
      _buildNavButton(context, 'Muestras', '/muestrasadm'),
      _buildNavButton(context, 'Perfil', '/profile'),
      
    ];
  }

  Widget _buildNavButton(BuildContext context, String label, String route) {
    return TextButton(
      onPressed: () {
        Navigator.of(context).pushNamed(route);
      },
      child: Text(label, style: const TextStyle(color: Colors.white)),
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
          _buildDrawerItem(context, 'Materiales', '/home-admin'),
          _buildDrawerItem(context, 'Solicitudes', '/solicitudes'),
          _buildDrawerItem(context, 'Incidencias', '/incidencias'), 
          _buildDrawerItem(context, 'Muestras', '/muestrasadm'),        
          _buildDrawerItem(context, 'Perfil', '/profile'),
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
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
