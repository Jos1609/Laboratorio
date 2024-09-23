class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Porfavor ingrese su correo';
    }
    final RegExp emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Ingrese un Correo válido';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Porfavor ingrese su contraseña';
    }
    if (value.length < 6) {
      return 'La contraseña debe contener al menos 6 caracteres';
    }
    return null;
  }
  static bool isValidNumber(String value) {
    return int.tryParse(value) != null;
  }
}
