import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:laboratorio/services/bar_nav_service.dart';
import 'package:laboratorio/ui/screens/login/login_viewmodel.dart';
import 'package:laboratorio/ui/widgets/custom_navigation_bar.dart';
import 'package:laboratorio/ui/widgets/navigation_drawer.dart';
import 'package:provider/provider.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKeyPassword = GlobalKey<FormState>();

  // Controladores para limpiar los campos después de actualizar la contraseña
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String name = "";
  String firstName = "";
  String lastName = "";
  String email = "";
  String userType = "";
  String avatarUrl =
      "https://thumbs.dreamstime.com/b/l%C3%ADnea-icono-del-negro-avatar-perfil-de-usuario-121102131.jpg";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      print('Current user: ${user?.uid}'); // Debug print

      if (user != null) {
        final userId = user.uid;
        final userType = await getUserType(userId);
        // Intentar cargar desde docente
        final docenteSnapshot = await FirebaseDatabase.instance
            .ref()
            .child('docente')
            .child(userId)
            .get();

        if (docenteSnapshot.exists) {
          print('Usuario encontrado en docente'); // Debug print
          final userData =
              Map<String, dynamic>.from(docenteSnapshot.value as Map);
          _updateUserData(userData, 'docente');
          return;
        }

        // Intentar cargar desde admin
        final adminSnapshot = await FirebaseDatabase.instance
            .ref()
            .child('admin')
            .child(userId)
            .get();

        if (adminSnapshot.exists) {
          print('Usuario encontrado en admin'); // Debug print
          final userData =
              Map<String, dynamic>.from(adminSnapshot.value as Map);
          _updateUserData(userData, 'admin');
          return;
        }
        final superadminSnapshot = await FirebaseDatabase.instance
            .ref()
            .child('superadmin')
            .child(userId)
            .get();

        if (superadminSnapshot.exists) {
          print('Usuario encontrado en superadmin'); // Debug print
          final userData =
              Map<String, dynamic>.from(superadminSnapshot.value as Map);
          _updateUserData(userData, 'superadmin');
          return;
        }
        this.userType = userType;

        print('Usuario no encontrado en ninguna colección'); // Debug print
      }
    } catch (e) {
      print('Error al cargar el perfil: $e'); // Debug print
    }
  }

  void _updateUserData(Map<String, dynamic> userData, String type) {
    setState(() {
      firstName = userData['nombres'] ?? '';
      lastName = userData['apellidos'] ?? '';
      name = '$firstName $lastName';
      email = userData['correo'] ?? '';
      userType = type;
      print(
          'Datos actualizados: $firstName $lastName $email $userType'); // Debug print
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: userType == 'admin' ? const GlobalNavigationBar() : null,
      drawer: userType == 'admin' && MediaQuery.of(context).size.width < 600
          ? const GlobalNavigationBar().buildCustomDrawer(context)
          : null,
      bottomNavigationBar:
          userType == 'docente' ? const CustomNavigationBar() : null,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: screenWidth > 600 ? 600 : screenWidth * 0.9,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: screenWidth > 600 ? 60 : 40,
                            backgroundImage: NetworkImage(avatarUrl),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            name,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            email,
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          TabBar(
                            controller: _tabController,
                            tabs: const [
                              Tab(text: 'Perfil'),
                              Tab(text: 'Contraseña'),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 500, // Aumentado para dar más espacio
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                SingleChildScrollView(
                                  child: _buildProfileForm(),
                                ),
                                SingleChildScrollView(
                                  child: _buildPasswordForm(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }



  Widget _buildPasswordForm() {
    final ValueNotifier<bool> _showCurrentPassword = ValueNotifier<bool>(false);
    final ValueNotifier<bool> _showNewPassword = ValueNotifier<bool>(false);
    final ValueNotifier<bool> _showConfirmPassword = ValueNotifier<bool>(false);

    return Form(
      key: _formKeyPassword,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cambiar Contraseña',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ValueListenableBuilder<bool>(
                    valueListenable: _showCurrentPassword,
                    builder: (context, showPassword, _) {
                      return TextFormField(
                        controller: _currentPasswordController,
                        obscureText: !showPassword,
                        decoration: InputDecoration(
                          labelText: 'Contraseña Actual',
                          labelStyle: TextStyle(color: Colors.grey[600]),
                          prefixIcon:
                              Icon(Icons.lock_outline, color: Colors.grey[600]),
                          suffixIcon: IconButton(
                            icon: Icon(
                              showPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey[600],
                            ),
                            onPressed: () {
                              _showCurrentPassword.value = !showPassword;
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Colors.blue, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese su contraseña actual';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  ValueListenableBuilder<bool>(
                    valueListenable: _showNewPassword,
                    builder: (context, showPassword, _) {
                      return TextFormField(
                        controller: _newPasswordController,
                        obscureText: !showPassword,
                        decoration: InputDecoration(
                          labelText: 'Nueva Contraseña',
                          labelStyle: TextStyle(color: Colors.grey[600]),
                          prefixIcon:
                              Icon(Icons.lock_outline, color: Colors.grey[600]),
                          suffixIcon: IconButton(
                            icon: Icon(
                              showPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey[600],
                            ),
                            onPressed: () {
                              _showNewPassword.value = !showPassword;
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Colors.blue, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese su nueva contraseña';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  ValueListenableBuilder<bool>(
                    valueListenable: _showConfirmPassword,
                    builder: (context, showPassword, _) {
                      return TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: !showPassword,
                        decoration: InputDecoration(
                          labelText: 'Confirmar Nueva Contraseña',
                          labelStyle: TextStyle(color: Colors.grey[600]),
                          prefixIcon:
                              Icon(Icons.lock_outline, color: Colors.grey[600]),
                          suffixIcon: IconButton(
                            icon: Icon(
                              showPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey[600],
                            ),
                            onPressed: () {
                              _showConfirmPassword.value = !showPassword;
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Colors.blue, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor confirme su nueva contraseña';
                          } else if (value != _newPasswordController.text) {
                            return 'Las contraseñas no coinciden';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _handlePasswordUpdate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shadowColor: Colors.blue.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Actualizar Contraseña',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileForm() {
    final loginViewModel = Provider.of<LoginViewModel>(context, listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Nombres:",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(firstName, style: Theme.of(context).textTheme.bodyLarge),
        ),
        const SizedBox(height: 16),
        Text(
          "Apellidos:",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(lastName, style: Theme.of(context).textTheme.bodyLarge),
        ),
        const SizedBox(height: 16),
        Text(
          "Correo electrónico:",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(email, style: Theme.of(context).textTheme.bodyLarge),
        ),
        const SizedBox(height: 16),
        Text(
          "Tipo de usuario:",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            userType.toUpperCase(),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              loginViewModel.signOut(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Cerrar Sesión',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handlePasswordUpdate() async {
    if (_formKeyPassword.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      Provider.of<LoginViewModel>(context, listen: false);

      if (user != null) {
        try {
          // Reautenticar al usuario antes de actualizar la contraseña
          AuthCredential credential = EmailAuthProvider.credential(
            email: user.email!,
            password: _currentPasswordController.text,
          );
          await user.reauthenticateWithCredential(credential);

          // Actualizar la contraseña
          await user.updatePassword(_newPasswordController.text);

          // Limpiar los controladores de texto después de la actualización
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Contraseña actualizada exitosamente')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al actualizar la contraseña: $e')),
          );
        }
      }
    }
  }
}
