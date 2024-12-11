import 'package:flutter/foundation.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:convert';
import 'package:intl/intl.dart';

class SolicitudesExporter {
  static Future<void> exportSolicitudes(List<Map<String, dynamic>> solicitudesFiltradas) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Solicitudes'];

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
      'Índice', 'Fecha', 'Solicitante', 'Curso', 'Hora inicio', 'Hora fin', 'Laboratorio', 'Material', 'Cantidad'
    ];
    for (int i = 0; i < headers.length; i++) {
      var cell = sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = headerStyle;
    }

    if (solicitudesFiltradas.isNotEmpty) {
      int rowIndex = 1;
      int indicator = 1;

      for (var solicitud in solicitudesFiltradas) {
        // Obtener materiales
        List<dynamic> materials = solicitud['materials'] != null
            ? solicitud['materials'] as List<dynamic>
            : [];

        int materialCount = materials.isNotEmpty ? materials.length : 1;

        // Combinar celdas de columnas comunes según el número de materiales
        sheetObject.merge(
            CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
            CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex + materialCount - 1));
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
            .value = IntCellValue(indicator);
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex)).cellStyle = cellStyle;

        sheetObject.merge(
            CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex),
            CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex + materialCount - 1));
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
            .value = TextCellValue(solicitud['date']?.toString() ?? '');
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex)).cellStyle = cellStyle;

        sheetObject.merge(
            CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex),
            CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex + materialCount - 1));
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
            .value = TextCellValue(solicitud['docente']?.toString() ?? '');
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex)).cellStyle = cellStyle;

        sheetObject.merge(
            CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex),
            CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex + materialCount - 1));
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
            .value = TextCellValue(solicitud['course']?.toString() ?? '');
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex)).cellStyle = cellStyle;
        
        sheetObject.merge(
            CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex),
            CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex + materialCount - 1));
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
            .value = TextCellValue(solicitud['startTime']?.toString() ?? '');
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex)).cellStyle = cellStyle;

        sheetObject.merge(
            CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex),
            CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex + materialCount - 1));
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
            .value = TextCellValue(solicitud['endTime']?.toString() ?? '');
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex)).cellStyle = cellStyle;

        sheetObject.merge(
            CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex),
            CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex + materialCount - 1));
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex))
            .value = TextCellValue(solicitud['laboratorio']?.toString() ?? '');
        sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex)).cellStyle = cellStyle;       

        // Agregar materiales
        if (materials.isNotEmpty) {
          for (var material in materials) {
            var materialMap = material as Map<dynamic, dynamic>;

            sheetObject
                .cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex))
                .value = TextCellValue(materialMap['name']?.toString() ?? '');
            sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex)).cellStyle = cellStyle;

            sheetObject
                .cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: rowIndex))
                .value = TextCellValue(materialMap['quantity']?.toString() ?? '');
            sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: rowIndex)).cellStyle = cellStyle;

            
            rowIndex++;
          }
        } else {
          sheetObject
              .cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex))
              .value = TextCellValue('Sin materiales');
          sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex)).cellStyle = cellStyle;

          rowIndex++;
        }

        indicator++;
      }
    } else {
      print('No hay solicitudes filtradas para exportar.');
    }

    if (kIsWeb) {
      final bytes = excel.encode();
      if (bytes != null) {
        final content = base64Encode(bytes);
        final date = DateFormat('yyyy-MM-dd-HH-mm').format(DateTime.now());
        html.AnchorElement(
            href: "data:application/octet-stream;base64,$content")
          ..setAttribute("download", "solicitudes_$date.xlsx")
          ..click();
      }
    } else {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final date = DateFormat('yyyy-MM-dd-HH-mm').format(DateTime.now());
        final filePath = '${directory.path}/solicitudes_$date.xlsx';
        final file = File(filePath);

        await file.writeAsBytes(excel.encode()!, flush: true);
        print('Archivo guardado en: $filePath');
      } catch (e) {
        print('Error al guardar el archivo: $e');
      }
    }
  }
}
