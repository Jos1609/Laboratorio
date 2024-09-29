import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:laboratorio/ui/widgets/recover_password_dialog.dart';
import 'package:provider/provider.dart';
import 'login_viewmodel.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/lab_illustration.dart';
import '../../widgets/footer_widget.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});


  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

void _checkUser() async {
  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    // Aquí verifica en Realtime Database para determinar si el usuario es admin o docente
    DatabaseEvent event = await FirebaseDatabase.instance
        .ref('admin/${currentUser.uid}')
        .once();

    if (event.snapshot.exists) {
      // El usuario es admin
      Navigator.pushReplacementNamed(context, '/home-admin');
    } else {
      // Verifica si es docente
      DatabaseEvent eventDocente = await FirebaseDatabase.instance
          .ref('docente/${currentUser.uid}')
          .once();

      if (eventDocente.snapshot.exists) {
        // El usuario es docente
        Navigator.pushReplacementNamed(context, '/home-docente');
      } else {
        // Usuario no encontrado en ninguno de los nodos
        await FirebaseAuth.instance.signOut();
        Navigator.pushReplacementNamed(context, '/'); // Redirige al login
      }
    }
  }
}


  @override

  void initState() {
  super.initState();
  _checkUser(); // Verifica el estado del usuario al iniciar la pantalla
}
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LoginViewModel>(context);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            return Row(
              children: [
                const Expanded(
                  child:
                      LabIllustration(), // Widget de ilustración del laboratorio
                ),
                Expanded(
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      _buildHeaderText(),
                      const SizedBox(height: 20),
                      Expanded(
                        child: Center(
                          child: _buildLoginForm(context, viewModel),
                        ),
                      ),
                      const FooterWidget(), // Widget del pie de página
                    ],
                  ),
                ),
              ],
            );
          } else {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildHeaderText(),
                const SizedBox(height: 20),
                _buildLoginForm(context, viewModel),
                const FooterWidget(), // Widget del pie de página
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildHeaderText() {
    return const Text(
      'Laboratorio de Ciencias Básicas',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black54,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildLoginForm(BuildContext context, LoginViewModel viewModel) {
  return Card(
    elevation: 5,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    margin: const EdgeInsets.symmetric(horizontal: 32.0),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            controller: _emailController,
            labelText: AppStrings.emailHint,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese su correo electrónico';
              }
              return Validators.validateEmail(value);
            },
            prefixIcon: const Icon(Icons.email),
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: _emailController.text.isEmpty ? Colors.red : Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _passwordController,
            labelText: AppStrings.passwordHint,
            obscureText: _obscurePassword,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese su contraseña';
              }
              return Validators.validatePassword(value);
            },
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: _passwordController.text.isEmpty ? Colors.red : Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 16),
          viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : CustomButton(
                  text: AppStrings.loginButton,
                  onPressed: () {
                    final email = _emailController.text.trim();
                    final password = _passwordController.text.trim();

                    if (email.isEmpty || password.isEmpty) {
                      setState(() {});
                    } else {
                      viewModel.signIn(email, password, context);
                    }
                  },
                ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const RecoverPasswordDialog(),
              );
            },
            child: const Text(
              '¿Olvidaste tu contraseña?',
              style: TextStyle(color: AppColors.primaryColor),
            ),
          ),
        ],
      ),
    ),
  );
}

}
