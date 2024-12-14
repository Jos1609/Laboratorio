import 'package:flutter/material.dart';
import 'package:laboratorio/data/models/user.dart';
import 'package:laboratorio/services/usuario_service.dart';
import 'package:laboratorio/ui/widgets/navigation_drawer.dart';

class RegistroUsuarioScreen extends StatefulWidget {
  const RegistroUsuarioScreen({Key? key}) : super(key: key);

  @override
  _RegistroUsuarioScreenState createState() => _RegistroUsuarioScreenState();
}

class _RegistroUsuarioScreenState extends State<RegistroUsuarioScreen> {
  final _formKey = GlobalKey<FormState>();
  final UsuarioService _usuarioService = UsuarioService();

  // Controladores para los campos
  final TextEditingController _nombresController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  String _tipoUsuario = 'docente';  // Valor por defecto

  Future<void> _registrarUsuario() async {
    if (_formKey.currentState!.validate()) {
      Usuario nuevoUsuario = Usuario(
        nombres: _nombresController.text.trim(),
        apellidos: _apellidosController.text.trim(),
        correo: _correoController.text.trim(),
        tipo: _tipoUsuario,
      );

      try {
        await _usuarioService.registrarUsuario(nuevoUsuario);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario registrado con éxito')),
        );
        _limpiarCampos();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar usuario: $e')),
        );
      }
    }
  }

  void _limpiarCampos() {
    _nombresController.clear();
    _apellidosController.clear();
    _correoController.clear();
    setState(() {
      _tipoUsuario = 'docente';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalNavigationBar(),
      drawer: MediaQuery.of(context).size.width < 600
          ? GlobalNavigationBar().buildCustomDrawer(context)
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nombres',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _nombresController,
                decoration: const InputDecoration(hintText: 'Ingrese los nombres'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              const Text(
                'Apellidos',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _apellidosController,
                decoration: const InputDecoration(hintText: 'Ingrese los apellidos'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              const Text(
                'Correo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _correoController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: 'Ingrese el correo electrónico'),
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Ingrese un correo válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              const Text(
                'Tipo de Usuario',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              DropdownButtonFormField<String>(
                value: _tipoUsuario,
                onChanged: (String? newValue) {
                  setState(() {
                    _tipoUsuario = newValue!;
                  });
                },
                items: const [
                  DropdownMenuItem(value: 'docente', child: Text('Docente')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                ],
              ),
              const SizedBox(height: 32),
              
              Center(
                child: ElevatedButton(
                  onPressed: _registrarUsuario,
                  child: const Text('Registrar Usuario'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
