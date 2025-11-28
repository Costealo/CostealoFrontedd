import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'dart:typed_data' show Uint8List;

class ExcelImportHelper {
  /// Importa productos desde un archivo Excel
  /// Retorna una lista de productos o null si hubo error/cancelación
  static Future<List<Map<String, dynamic>>?> importProductsFromExcel() async {
    try {
      // Abrir selector de archivos
      // withData: true fuerza la lectura de bytes (necesario en web)
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: true, // Fuerza la carga de bytes en web
      );

      if (result == null) {
        return null; // Usuario canceló
      }

      PlatformFile file = result.files.single;

      // Obtener bytes del archivo
      Uint8List? bytes = file.bytes;

      if (bytes == null || bytes.isEmpty) {
        throw Exception(
          'No se pudo leer el archivo. Asegúrate de:\n'
          '1. Estar usando un navegador compatible (Chrome o Edge)\n'
          '2. El archivo no esté corrupto\n'
          '3. Tener permisos para leer el archivo',
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
