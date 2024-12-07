import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
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
   final email = _emailController.text.trim();
   
   if (email.isEmpty || !email.contains('@')) {
     showAutoDismissAlert(context, 'Ingrese un correo válido', Colors.red);
     return;
   }

   setState(() => _isLoading = true);

   try {
     await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
     // ignore: use_build_context_synchronously
     showAutoDismissAlert(context, 'Correo de recuperación enviado', Colors.green);
     // ignore: use_build_context_synchronously
     Navigator.pop(context);
   } catch (e) {
     showAutoDismissAlert(
       context, 
       'No existe una cuenta con ese correo', 
       Colors.red
     );
   }

   setState(() => _isLoading = false);
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
         if (_isLoading)
           const CircularProgressIndicator()
         else
           ElevatedButton(
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
         onPressed: () => Navigator.pop(context),
         child: const Text('Cancelar'),
       ),
     ],
   );
 }
}