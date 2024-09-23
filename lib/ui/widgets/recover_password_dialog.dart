import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../data/repositories/auth_repository.dart';
import '../../../ui/widgets/auto_dismiss_alert.dart';

class RecoverPasswordDialog extends StatefulWidget {
  const RecoverPasswordDialog({super.key});

  @override
  _RecoverPasswordDialogState createState() => _RecoverPasswordDialogState();
}

class _RecoverPasswordDialogState extends State<RecoverPasswordDialog> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _recoverPassword(BuildContext context) async {
    final authRepository = Provider.of<AuthRepository>(context, listen: false);
    final email = _emailController.text.trim();

    // Validar si el formato del correo es válido
    if (Validators.validateEmail(email) != null) {
      showAutoDismissAlert(context, 'Por favor, ingrese un correo electrónico válido.', Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Intentar obtener el usuario con el correo proporcionado
      final methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      
      if (methods.isNotEmpty) {
        // Si hay métodos de inicio de sesión disponibles, significa que el correo existe
        await authRepository.sendPasswordResetEmail(email);
        showAutoDismissAlert(context, 'Se ha enviado un enlace de recuperación a su correo electrónico.', Colors.blue);
        Navigator.of(context).pop();
      } else {
        // Si no hay métodos de inicio de sesión, el correo no está registrado
        showAutoDismissAlert(context, 'No existe una cuenta con esa dirección de correo.', Colors.red);
      }
    } on FirebaseAuthException {
      showAutoDismissAlert(context, 'Hubo un error al intentar verificar el correo.', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Recupera tu Contraseña'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Correo Electrónico',
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          _isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: () => _recoverPassword(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bajoColor,
                  ),
                  child: const Text('Recuperar Contraseña'),
                ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}
