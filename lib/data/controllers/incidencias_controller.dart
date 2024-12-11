// lib/data/controllers/incidencias_controller.dart

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../data/repositories/incidencia_repository.dart';
import '../../../data/models/incidencia_model.dart';
class IncidenciasController extends ChangeNotifier {
 final IncidenciaRepository _repository = IncidenciaRepository();
 String _searchText = '';
 String _selectedDateFilter = '';
 List<Incidencia> _cachedIncidencias = [];
 bool _isLoading = true;
 String _currentFilter = 'todas';

 String get searchText => _searchText;
 String get selectedDateFilter => _selectedDateFilter;
 String get currentFilter => _currentFilter;
 bool get isLoading => _isLoading;

 IncidenciasController() {
   _initializeData();
 }

 void _initializeData() {
   _repository.getIncidenciasStream().listen((event) {
     if (event.snapshot.value != null) {
       final Map<dynamic, dynamic> data = event.snapshot.value as Map;
       _cachedIncidencias = data.entries.map((entry) {
         return Incidencia.fromMap(entry.value as Map, entry.key);
       }).toList();
       _isLoading = false;
       notifyListeners();
     }
   });
 }

 void updateFilter(String filter) {
   _currentFilter = filter;
   notifyListeners();
 }

 void updateSearchText(String value) {
   _searchText = value;
   notifyListeners();
 }

 void updateDateFilter(String value) {
   _selectedDateFilter = value;
   notifyListeners();
 }

 void clearDateFilter() {
   _selectedDateFilter = '';
   notifyListeners();
 }

 Stream<DatabaseEvent> get incidenciasStream => _repository.getIncidenciasStream();

 List<Incidencia> get filteredIncidencias {
   List<Incidencia> incidencias = _cachedIncidencias;
   
   // Filtro por estado
   if (_currentFilter == 'pendientes') {
     incidencias = incidencias.where((inc) => inc.estado == 'Pendiente').toList();
   } else if (_currentFilter == 'devueltas') {
     incidencias = incidencias.where((inc) => inc.estado == 'Devuelto').toList();
   }
   
   // Filtro por búsqueda y fecha
   return incidencias.where((incidencia) {
     bool matchesSearch = incidencia.nombrePractica.toLowerCase().contains(_searchText.toLowerCase()) ||
         incidencia.curso.toLowerCase().contains(_searchText.toLowerCase());
     bool matchesDate = _selectedDateFilter.isEmpty ||
         incidencia.fecha.startsWith(_selectedDateFilter);
     return matchesSearch && matchesDate;
   }).toList();
 }

 Future<void> updateIncidenciaStatus(String id, String status) async {
   try {
     await _repository.updateIncidenciaStatus(id, status);
   } catch (e) {
     throw Exception('Error al actualizar el estado: $e');
   }
 }

 Map<String, int> calculateStats(List<Incidencia> incidencias) {
   int pendientes = 0;
   int devueltas = 0;

   for (var incidencia in incidencias) {
     if (incidencia.estado == 'Pendiente') {
       pendientes++;
     } else {
       devueltas++;
     }
   }

   return {
     'total': incidencias.length,
     'pendientes': pendientes,
     'devueltas': devueltas,
   };
 }
}