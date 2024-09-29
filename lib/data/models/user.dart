class Usuario {
  final String nombres;
  final String apellidos;
  final String correo;
  final String tipo;

  Usuario({
    required this.nombres,
    required this.apellidos,
    required this.correo,
    required this.tipo,
  });

  // Convertir a mapa para guardar en Firebase
  Map<String, dynamic> toMap() {
    return {
      'nombres': nombres,
      'apellidos': apellidos,
      'correo': correo,
      'tipo': tipo,
    };
  }
}
