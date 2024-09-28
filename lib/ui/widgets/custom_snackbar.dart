import 'package:flutter/material.dart';

class CustomSnackbar {
  static void show(BuildContext context, String message, Color textColor, IconData icon) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(icon, color: textColor),
          const SizedBox(width: 8), // Espacio entre el ícono y el texto
          Expanded(child: Text(message, style: TextStyle(color: textColor))),
        ],
      ),
      backgroundColor: Colors.white, // Color de fondo de la Snackbar
      duration: const Duration(seconds: 2), // Duración de la Snackbar
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
