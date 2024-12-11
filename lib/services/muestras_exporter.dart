// lib/data/exporters/muestras_exporter.dart

import 'package:flutter/foundation.dart';
import 'package:excel/excel.dart';
import 'package:laboratorio/data/models/muestra.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:html' as html;
import 'dart:convert';
import 'package:intl/intl.dart';

class MuestrasExporter {
  static Future<void> exportMuestras(List<Muestra> muestras) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Muestras'];

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
      'Título',
      'Curso',
      'Fecha Dejado',
      'Fecha Recogido',
      'Estado',
    ];

    // Establecer encabezados
    for (int i = 0; i < headers.length; i++) {
      var cell = sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = headerStyle;
    }

    // Llenar datos
    if (muestras.isNotEmpty) {
      for (int i = 0; i < muestras.length; i++) {
        var muestra = muestras[i];
        int rowIndex = i + 1;

        // Índice
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
            .value = IntCellValue(i + 1);

        // Título
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
            .value = TextCellValue(muestra.title);

        // Curso
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
            .value = TextCellValue(muestra.course);

        // Fecha Dejado
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
            .value = TextCellValue(muestra.date ?? 'No especificada');

        // Fecha Recogido
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
            .value = TextCellValue(muestra.dateR ?? 'No recogida');

        // Estado
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
            .value = TextCellValue(muestra.estado);

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
          ..setAttribute("download", "muestras_$date.xlsx")
          ..click();
      }
    } else {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final date = DateFormat('yyyy-MM-dd-HH-mm').format(DateTime.now());
        final filePath = '${directory.path}/muestras_$date.xlsx';
        final file = File(filePath);
        await file.writeAsBytes(excel.encode()!, flush: true);
        print('Archivo guardado en: $filePath');
      } catch (e) {
        print('Error al guardar el archivo: $e');
      }
    }
  }
}