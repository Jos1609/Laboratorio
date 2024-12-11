import 'package:equatable/equatable.dart';

class LabMaterial extends Equatable {
  final String name;
  final String quantity;
  final String unit;
  final String? ubicacion;
  final String? tipo;

  const LabMaterial({
    required this.name,
    required this.quantity,
    required this.unit,
    this.ubicacion,
    this.tipo,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'ubicacion': ubicacion,
      'tipo': tipo,
    };
  }

  factory LabMaterial.fromMap(Map<String, dynamic> map) {
    return LabMaterial(
      name: map['name'],
      quantity: map['quantity'],
      unit: map['unit'],
      ubicacion: map['ubicacion'],
      tipo: map['tipo'],
    );
  }

  @override
  List<Object?> get props => [name, quantity, unit, ubicacion, tipo];
}