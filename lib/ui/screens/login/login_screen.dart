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

  @override
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
