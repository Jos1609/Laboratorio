class Incidencia {
  String nombrePractica;
  String lugar;
  String observador;
  String curso;
  String incidente;
  String tratamiento;
  String derivacion;
  String compromiso;
  String estado;
  String fecha;

  Incidencia({
    required this.nombrePractica,
    required this.lugar,
    required this.observador,
    required this.curso,
    required this.incidente,
    required this.tratamiento,
    required this.derivacion,
    required this.compromiso,
    required this.estado,
    required this.fecha,
  });

  Map<String, dynamic> toMap() {
    return {
      'nombrePractica': nombrePractica,
      'lugar': lugar,
      'observador': observador,
      'curso': curso,
      'incidente': incidente,
      'tratamiento': tratamiento,
      'derivacion': derivacion,
      'compromiso': compromiso,
      'estado': estado,
      'fecha': fecha,
    };
  }
}
