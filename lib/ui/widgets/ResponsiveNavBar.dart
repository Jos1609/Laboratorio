import 'package:flutter/material.dart';

class ResponsiveNavBar extends StatelessWidget {
  const ResponsiveNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      suffixIcon: const Icon(Icons.search),
                    ),
                  ),
                ),
                if (constraints.maxWidth > 600) ...[
                  const SizedBox(width: 16),
                  _buildNavButton(Icons.home, 'Materiales', () {}),
                  _buildNavButton(Icons.add_alarm, 'Equipos', () {}),
                  _buildNavButton(Icons.outbox, 'Salida de equipos', () {}),
                  _buildNavButton(Icons.report_problem, 'Incidencias', () {}),
                ],
              ],
            );
          },
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menú',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            _buildDrawerItem(Icons.home, 'Materiales', () {}),
            _buildDrawerItem(Icons.add_alarm, 'Equipos', () {}),
            _buildDrawerItem(Icons.outbox, 'Salida de equipos', () {}),
            _buildDrawerItem(Icons.report_problem, 'Incidencias', () {}),
            _buildDrawerItem(Icons.logout, 'Cerrar Sesión', () {
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(IconData icon, String label, VoidCallback onPressed) {
    return TextButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: onPressed,
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }
}

void main() {
  runApp(const MaterialApp(home: ResponsiveNavBar()));
}