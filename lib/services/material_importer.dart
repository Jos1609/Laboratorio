import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:laboratorio/data/repositories/material_repository.dart';
import 'package:laboratorio/ui/widgets/custom_snackbar.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:excel/excel.dart';

class MaterialImporter {
  final MaterialRepository _materialRepo;

  MaterialImporter(this._materialRepo);

  Future<void> importMaterials(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null && result.files.isNotEmpty) {
      Uint8List? bytes;

      if (kIsWeb) {
        bytes = result.files.first.bytes;
      } else {
        String? filePath = result.files.single.path;
        if (filePath != null) {
          bytes = File(filePath).readAsBytesSync();
        }
      }

      if (bytes != null) {
        var excel = Excel.decodeBytes(bytes);

        for (var table in excel.tables.keys) {
          for (var row in excel.tables[table]!.rows) {
            String materialName = row[0]?.value?.toString() ?? '';
            int? stock = (row[1]?.value is int)
                ? (row[1]?.value as int)
                : int.tryParse(row[1]?.value?.toString() ?? '');
            String unit = row[2]?.value?.toString() ?? '';

            if (materialName.isNotEmpty && stock != null && unit.isNotEmpty) {
              try {
                await _materialRepo.addMaterial(materialName, stock, unit);
                print('Material "$materialName" subido correctamente.');
              } catch (e) {
                CustomSnackbar.show(context, 'Error al agregar el material: $e',
                    Colors.red, Icons.error);
              }
            } else {}
          }
        }

        CustomSnackbar.show(context, 'Material agregado correctamente.',
            Colors.green, Icons.check_circle);
      } else {}
    } else {}
  }
}