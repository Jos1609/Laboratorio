import 'package:equatable/equatable.dart';

class LabMaterial extends Equatable {
  final String name;
  final String quantity;
  final String unit;

  const LabMaterial({
    required this.name,
    required this.quantity,
    required this.unit,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
    };
  }

  factory LabMaterial.fromMap(Map<String, dynamic> map) {
    return LabMaterial(
      name: map['name'],
      quantity: map['quantity'],
      unit: map['unit'],
    );
  }

  @override
  List<Object> get props => [name, quantity, unit];
}
