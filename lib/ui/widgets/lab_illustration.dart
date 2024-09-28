import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class LabIllustration extends StatelessWidget {
  const LabIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8F5E9), Color(0xFFB2DFDB)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.blur_circular,
                  size: 150,
                  color: AppColors.primaryColor.withOpacity(0.2),
                ),
                const Icon(
                  Icons.science,
                  size: 120,
                  color: AppColors.primaryColor,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Sistema de Control',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[800],
                shadows: [
                  Shadow(
                    offset: const Offset(1, 1),
                    blurRadius: 3,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Laboratorio de Ciencias Básicas',
              style: TextStyle(
                fontSize: 18,
                color: Colors.blueGrey[600],
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIconWithText(Icons.biotech, 'Biología'),
                const SizedBox(width: 24),
                _buildIconWithText(Icons.architecture, 'Física'),
                const SizedBox(width: 24),
                _buildIconWithText(Icons.science, 'Química'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconWithText(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, size: 40, color: AppColors.primaryColor),
        const SizedBox(height: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: Colors.blueGrey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}