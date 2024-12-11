import 'package:flutter/foundation.dart';
import 'package:laboratorio/data/models/muestra.dart';
import 'package:laboratorio/services/muestra_service.dart';

class MuestrasController extends ChangeNotifier {
  final MuestraService _service = MuestraService();
  String _searchText = '';
  String _selectedDateFilter = '';
  List<Muestra> _cachedMuestras = [];
  bool _isLoading = true;

  String get searchText => _searchText;
  String get selectedDateFilter => _selectedDateFilter;
  bool get isLoading => _isLoading;

  MuestrasController() {
    _initializeData();
  }

 void _initializeData() {
  _service.getMuestrasStream().listen((event) {
    if (event.snapshot.value != null) {
      final Map<dynamic, dynamic> data = event.snapshot.value as Map;
      _cachedMuestras = data.entries.map((entry) {
        // Convertir el Map<dynamic, dynamic> a Map<String, dynamic>
        final Map<String, dynamic> muestraMap = {};
        (entry.value as Map<dynamic, dynamic>).forEach((key, value) {
          muestraMap[key.toString()] = value;
        });
        return Muestra.fromMap(muestraMap, entry.key.toString());
      }).toList();
      _isLoading = false;
      notifyListeners();
    }
  });
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

  List<Muestra> get filteredMuestras {
    return _cachedMuestras.where((muestra) {
      bool matchesSearch = muestra.title.toLowerCase().contains(_searchText.toLowerCase()) ||
          muestra.course.toLowerCase().contains(_searchText.toLowerCase());
      bool matchesDate = _selectedDateFilter.isEmpty ||
          muestra.date?.startsWith(_selectedDateFilter) == true;
      return matchesSearch && matchesDate;
    }).toList();
  }
}