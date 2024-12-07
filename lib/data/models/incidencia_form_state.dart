import 'package:flutter/material.dart';

@immutable
class IncidenciaFormState {
 final String nombrePractica;
 final String lugar;
 final String observador;
 final String curso;
 final String incidente;
 final String tratamiento;
 final String derivacion;
 final String compromiso;
 final String estado;
 final DateTime fecha;

IncidenciaFormState({
  this.nombrePractica = '',
  this.lugar = '',
  this.observador = '',
  this.curso = '',
  this.incidente = '',
  this.tratamiento = '',
  this.derivacion = '', 
  this.compromiso = '',
  this.estado = 'Pendiente',
  DateTime? fecha,
}) : fecha = fecha ?? DateTime.now();

 IncidenciaFormState copyWith({
   String? nombrePractica,
   String? lugar,
   String? observador,
   String? curso,
   String? incidente,
   String? tratamiento,
   String? derivacion,
   String? compromiso,
   String? estado,
   DateTime? fecha,
 }) {
   return IncidenciaFormState(
     nombrePractica: nombrePractica ?? this.nombrePractica,
     lugar: lugar ?? this.lugar,
     observador: observador ?? this.observador,
     curso: curso ?? this.curso,
     incidente: incidente ?? this.incidente,
     tratamiento: tratamiento ?? this.tratamiento,
     derivacion: derivacion ?? this.derivacion,
     compromiso: compromiso ?? this.compromiso,
     estado: estado ?? this.estado,
     fecha: fecha ?? this.fecha,
   );
 }
}