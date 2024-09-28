import 'package:flutter/material.dart';

class AutoDismissAlert extends StatelessWidget {
  final String message;
  final Color backgroundColor;

  const AutoDismissAlert({
    super.key,
    required this.message,
    required this.backgroundColor, // Color como parámetro obligatorio
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: backgroundColor, // Usa el color proporcionado
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.white, // Color del texto
              fontSize: 16.0,
            ),
          ),
        ),
      ),
    );
  }
}

// Función para mostrar la alerta
void showAutoDismissAlert(BuildContext context, String message, Color backgroundColor) {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => AutoDismissAlert(
      message: message,
      backgroundColor: backgroundColor, // Pasar el color al widget
    ),
  );

  overlay.insert(overlayEntry);

  // Eliminar la alerta después de 2 segundos de manera segura
  Future.delayed(const Duration(seconds: 2), () {
    if (overlayEntry.mounted) {
      overlayEntry.remove();
    }
  });
}
