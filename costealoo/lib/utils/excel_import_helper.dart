import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
// Importación condicional para evitar dart:io en web
import 'dart:typed_data' show Uint8List;

class ExcelImportHelper {
  /// Importa productos desde un archivo Excel
  /// Retorna una lista de productos o null si hubo error/cancelación
  static Future<List<Map<String, dynamic>>?> importProductsFromExcel() async {
    try {
      // Abrir selector de archivos
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result == null) {
        return null; // Usuario canceló
      }

      // Leer el archivo Excel
      // En Web usamos bytes directamente
      Uint8List? bytes = result.files.single.bytes;

      if (bytes == null) {
        throw Exception(
          'No se pudo leer el archivo. Asegúrate de estar usando '
          'un navegador compatible o intenta con otro archivo.',
        );
      }

      var excel = Excel.decodeBytes(bytes);

      // Obtener la primera hoja
      if (excel.tables.isEmpty) {
        throw Exception('El archivo Excel está vacío');
      }

      var table = excel.tables[excel.tables.keys.first];
      if (table == null || table.rows.isEmpty) {
        throw Exception('La hoja está vacía');
      }

      // Parsear productos (asumiendo primera fila son headers)
      List<Map<String, dynamic>> products = [];

      // Saltar la primera fila (headers)
      for (int i = 1; i < table.rows.length; i++) {
        var row = table.rows[i];

        // Verificar que la fila tenga al menos el nombre del producto
        if (row.length < 2 || row[1]?.value == null) {
          continue; // Saltar filas vacías
        }

        products.add({
          'id': row.isNotEmpty && row[0]?.value != null
              ? row[0]!.value.toString()
              : '',
          'name': row.length > 1 && row[1]?.value != null
              ? row[1]!.value.toString()
              : '',
          'price': row.length > 2 && row[2]?.value != null
              ? row[2]!.value.toString()
              : '',
          'unit': row.length > 3 && row[3]?.value != null
              ? row[3]!.value.toString()
              : '',
        });
      }

      if (products.isEmpty) {
        throw Exception('No se encontraron productos en el archivo');
      }

      return products;
    } catch (e) {
      rethrow; // Re-lanzar para que el llamador maneje el error
    }
  }
}
