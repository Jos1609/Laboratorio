import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:html' as html;
import 'dart:convert';

class MaterialExporter {
  Future<void> exportMaterials() async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Materiales'];

    CellStyle cellStyle = CellStyle(
      fontFamily: getFontFamily(FontFamily.Calibri),
      fontSize: 14,
      bold: true,
      underline: Underline.Single,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    var headers = ['Indice', 'Material', 'Cantidad', 'Estado'];
    for (int i = 0; i < headers.length; i++) {
      var cell = sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = cellStyle;
    }

    DatabaseReference materialsRef =
        FirebaseDatabase.instance.ref().child('materiales');

    DataSnapshot snapshot = await materialsRef.get();

    if (snapshot.exists) {
      Map<dynamic, dynamic> materialsMap =
          snapshot.value as Map<dynamic, dynamic>;

      int rowIndex = 1;
      int indicator = 1;
      materialsMap.forEach((key, value) {
        var material = value as Map<dynamic, dynamic>;

        sheetObject
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
            .value = IntCellValue(indicator);
        sheetObject
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
            .value = TextCellValue(material['name']);
        sheetObject
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
            .value = IntCellValue(material['stock']);
        sheetObject
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
            .value = TextCellValue(material['unit']);

        rowIndex++;
        indicator++;
      });
    } else {
      print('No se encontraron materiales en Firebase.');
    }

    if (kIsWeb) {
      final bytes = excel.encode();
      if (bytes != null) {
        final content = base64Encode(bytes);
        html.AnchorElement(
            href: "data:application/octet-stream;base64,$content")
          ..setAttribute("download", "materiales.xlsx")
          ..click();
      }
    } else {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/materiales.xlsx';
        final file = File(filePath);

        await file.writeAsBytes(excel.encode()!, flush: true);
        print('Archivo guardado en: $filePath');
      } catch (e) {
        print('Error al guardar el archivo: $e');
      }
    }
  }
}