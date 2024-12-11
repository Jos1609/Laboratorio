// lib/data/exporters/incidencias_exporter.dart

import 'package:flutter/foundation.dart';
import 'package:excel/excel.dart';
import 'package:laboratorio/data/models/incidencia_model.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:html' as html;
import 'dart:convert';
import 'package:intl/intl.dart';

class IncidenciasExporter {
  static Future<void> exportIncidencias(List<Incidencia> incidencias) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Incidencias'];

    CellStyle headerStyle = CellStyle(
      fontFamily: getFontFamily(FontFamily.Calibri),
      fontSize: 14,
      bold: true,
      underline: Underline.Single,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    CellStyle cellStyle = CellStyle(
      fontFamily: getFontFamily(FontFamily.Calibri),
      fontSize: 12,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    var headers = [
      'Índice',
      'Fecha',
      'Curso',
      'Compromiso',
      'Derivación',
      'Estado',
      'Incidente',
      'Lugar',
      'Nombre Práctica',
      'Observador',
      'Tratamiento'
    ];

    // Establecer encabezados
    for (int i = 0; i < headers.length; i++) {
      var cell = sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = headerStyle;
    }

    // Llenar datos
    if (incidencias.isNotEmpty) {
      for (int i = 0; i < incidencias.length; i++) {
        var incidencia = incidencias[i];
        int rowIndex = i + 1;

        // Índice
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
            .value = IntCellValue(i + 1);
        
        // Fecha
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
            .value = TextCellValue(incidencia.fecha);

        // Curso
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
            .value = TextCellValue(incidencia.curso);

        // Compromiso
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
            .value = TextCellValue(incidencia.compromiso);

        // Derivación
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
            .value = TextCellValue(incidencia.derivacion);

        // Estado
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
            .value = TextCellValue(incidencia.estado);

        // Incidente
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex))
            .value = TextCellValue(incidencia.incidente);

        // Lugar
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex))
            .value = TextCellValue(incidencia.lugar);

        // Nombre Práctica
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: rowIndex))
            .value = TextCellValue(incidencia.nombrePractica);

        // Observador
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: rowIndex))
            .value = TextCellValue(incidencia.observador);

        // Tratamiento
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: rowIndex))
            .value = TextCellValue(incidencia.tratamiento);

        // Aplicar estilo a todas las celdas
        for (int j = 0; j < headers.length; j++) {
          sheetObject
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: j, rowIndex: rowIndex))
              .cellStyle = cellStyle;
        }
      }
    }

    // Exportar el archivo
    if (kIsWeb) {
      final bytes = excel.encode();
      if (bytes != null) {
        final content = base64Encode(bytes);
        final date = DateFormat('yyyy-MM-dd-HH-mm').format(DateTime.now());
        html.AnchorElement(
            href: "data:application/octet-stream;base64,$content")
          ..setAttribute("download", "incidencias_$date.xlsx")
          ..click();
      }
    } else {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final date = DateFormat('yyyy-MM-dd-HH-mm').format(DateTime.now());
        final filePath = '${directory.path}/incidencias_$date.xlsx';
        final file = File(filePath);
        await file.writeAsBytes(excel.encode()!, flush: true);
        print('Archivo guardado en: $filePath');
      } catch (e) {
        print('Error al guardar el archivo: $e');
      }
    }
  }
}