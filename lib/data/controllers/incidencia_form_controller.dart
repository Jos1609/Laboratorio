
import 'package:flutter/material.dart';
import '../models/incidencia_form_state.dart';
import '../../../data/repositories/incidencia_repository.dart';
import '../../../data/models/incidencia_model.dart';
import 'package:intl/intl.dart';

class IncidenciaFormController extends ChangeNotifier {
 final _formKey = GlobalKey<FormState>();
 final _repository = IncidenciaRepository();
 IncidenciaFormState _formState = IncidenciaFormState();

 GlobalKey<FormState> get formKey => _formKey;
 IncidenciaFormState get formState => _formState;

 void updateFormField(String field, dynamic value) {
   switch (field) {
     case 'nombrePractica':
       _formState = _formState.copyWith(nombrePractica: value as String);
       break;
     case 'lugar':
       _formState = _formState.copyWith(lugar: value as String);
       break;
     case 'observador':
       _formState = _formState.copyWith(observador: value as String);
       break;
     case 'curso':
       _formState = _formState.copyWith(curso: value as String);
       break;
     case 'incidente':
       _formState = _formState.copyWith(incidente: value as String);
       break;
     case 'tratamiento':
       _formState = _formState.copyWith(tratamiento: value as String);
       break;
     case 'derivacion':
       _formState = _formState.copyWith(derivacion: value as String);
       break;
     case 'compromiso':
       _formState = _formState.copyWith(compromiso: value as String);
       break;
     case 'estado':
       _formState = _formState.copyWith(estado: value as String);
       break;
     case 'fecha':
       _formState = _formState.copyWith(fecha: value as DateTime);
       break;
   }
   notifyListeners();
 }

 Future<void> submitForm(BuildContext context) async {
   if (!_formKey.currentState!.validate()) return;
   
   _formKey.currentState!.save();
   
   try {
     final incidencia = Incidencia(
       nombrePractica: _formState.nombrePractica,
       lugar: _formState.lugar,
       observador: _formState.observador,
       curso: _formState.curso,
       incidente: _formState.incidente,
       tratamiento: _formState.tratamiento,
       derivacion: _formState.derivacion,
       compromiso: _formState.compromiso,
       estado: _formState.estado,
       fecha: DateFormat('yyyy-MM-dd HH:mm').format(_formState.fecha),
     );

     await _repository.addIncidencia(incidencia);
     
     // ignore: use_build_context_synchronously
     Navigator.of(context).pop();
     // ignore: use_build_context_synchronously
     ScaffoldMessenger.of(context).showSnackBar(
       const SnackBar(content: Text('Incidencia registrada exitosamente')),
     );
   } catch (error) {
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text('Error al registrar la incidencia: $error')),
     );
   }
 }
}