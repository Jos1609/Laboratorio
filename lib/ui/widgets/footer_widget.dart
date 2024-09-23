import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Importar FontAwesome
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';

class FooterWidget extends StatelessWidget {
  const FooterWidget({super.key});
// Función para abrir el enlace de GitHub
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'No se pudo abrir $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'Desarrollado por Jos',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.github, color: AppColors.primaryColor),
                onPressed: () {
                   _launchURL('https://github.com/Jos1609');
                },
              ),
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.linkedin, color: AppColors.primaryColor),
                onPressed: () {
                  _launchURL('https://pe.linkedin.com/in/jose-melquiades-quispe-mondragon-613800269');
                },
              ),
              // Añadir más iconos según sea necesario
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '© 2024 Jos. Todos los derechos reservados.',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
