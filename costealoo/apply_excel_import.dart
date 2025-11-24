import 'dart:io';

void main() async {
  print('=== Implementando funcionalidad de importación de Excel ===\n');

  final projectPath = r'c:\costealo\CostealoFrontedd-1\costealoo';
  final selectionScreenPath =
      '$projectPath\\lib\\screens\\database\\database_selection_screen.dart';
  final databaseScreenPath =
      '$projectPath\\lib\\screens\\database\\database_screen.dart';

  //  1. Crear backups
  print('1. Creando backups...');
  await File(selectionScreenPath).copy('$selectionScreenPath.backup');
  await File(databaseScreenPath).copy('$databaseScreenPath.backup');
  print('   ✓ Backups creados\n');

  // ===== MODIFICAR database_selection_screen.dart =====
  print('2. Modificando database_selection_screen.dart...');

  var content = await File(selectionScreenPath).readAsString();

  // 2.1 Agregar import
  const importLine =
      "import 'package:costealoo/utils/excel_import_helper.dart';";
  if (!content.contains(importLine)) {
    content = content.replaceFirst(
      "import 'package:costealoo/screens/sheets/new_sheet_screen.dart';",
      "import 'package:costealoo/screens/sheets/new_sheet_screen.dart';\r\n$importLine",
    );
    print('   ✓ Import agregado');
  } else {
    print('   - Import ya existe');
  }

  // 2.2 Agregar método _importFromExcel
  const methodToAdd = r'''

  Future<void> _importFromExcel() async {
    try {
      final products = await ExcelImportHelper.importProductsFromExcel();
      
      if (products == null) return; // Usuario canceló
      
      final user = AuthService().currentUser;
      final companyName = (user?.nombre != null && user!.nombre.isNotEmpty)
          ? user.nombre
          : 'Mi Empresa';
      
      final dbResult = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DatabaseScreen(
            initialName: companyName,
            preLoadedProducts: products,
          ),
        ),
      );
      
      if (dbResult != null && dbResult is Map && dbResult['published'] == true) {
        _loadDatabases();
      }
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${products.length} productos importados correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al importar archivo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
''';

  if (!content.contains('_importFromExcel')) {
    final pattern = RegExp(
      r'(  void _createSheetFromDatabase\(Map<String, dynamic> database\) \{[^\}]*\}[^\}]*\}[\r\n]+)',
    );
    content = content.replaceFirst(pattern, '\\1$methodToAdd\r\n');
    print('   ✓ Método _importFromExcel agregado');
  } else {
    print('   - Método _importFromExcel ya existe');
  }

  // 2.3 Cambiar comentario del botón
  content = content.replaceAll(
    '// Botón Exportar de archivo',
    '// Botón Importar archivo',
  );

  // 2.4 Cambiar onPressed y label del botón
  const oldButtonCode = r'''onPressed: () {
                            // TODO: Implementar importar desde archivo
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Importar desde archivo - Próximamente',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Exportar de archivo'),''';

  const newButtonCode = r'''onPressed: _importFromExcel,
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Importar archivo'),''';

  content = content.replaceAll(oldButtonCode, newButtonCode);
  print('   ✓ Botón actualizado');

  // Guardar cambios
  await File(selectionScreenPath).writeAsString(content);

  // ===== MODIFICAR database_screen.dart =====
  print('\n3. Modificando database_screen.dart...');

  content = await File(databaseScreenPath).readAsString();

  // 3.1 Modificar constructor
  const oldConstructor = r'''class DatabaseScreen extends StatefulWidget {
  final String initialName;

  const DatabaseScreen({super.key, this.initialName = 'Nueva Base de Datos'});''';

  const newConstructor = r'''class DatabaseScreen extends StatefulWidget {
  final String initialName;
  final List<Map<String, dynamic>>? preLoadedProducts;

  const DatabaseScreen({
    super.key,
    this.initialName = 'Nueva Base de Datos',
    this.preLoadedProducts,
  });''';

  content = content.replaceFirst(oldConstructor, newConstructor);
  print('   ✓ Constructor modificado');

  // 3.2 Modificar initState
  const oldInitState = r'''  @override
  void initState() {
    super.initState();
    // Iniciar con 10 filas vacías
    for (int i = 0; i < 10; i++) {
      _addNewRow();
    }
  }''';

  const newInitState = r'''  @override
  void initState() {
    super.initState();
    // Si hay productos pre-cargados, cargarlos
    if (widget.preLoadedProducts != null && widget.preLoadedProducts!.isNotEmpty) {
      for (var product in widget.preLoadedProducts!) {
        productRows.add({
          'id': TextEditingController(text: product['id']?.toString() ?? ''),
          'name': TextEditingController(text: product['name']?.toString() ?? ''),
          'price': TextEditingController(text: product['price']?.toString() ?? ''),
          'unit': TextEditingController(text: product['unit']?.toString() ?? ''),
        });
      }
    } else {
      // Iniciar con 10 filas vacías
      for (int i = 0; i < 10; i++) {
        _addNewRow();
      }
    }
  }''';

  content = content.replaceFirst(oldInitState, newInitState);
  print('   ✓ initState modificado');

  // Guardar cambios
  await File(databaseScreenPath).writeAsString(content);

  // Resumen
  print('\n=== Cambios completados exitosamente ===\n');
  print('Archivos modificados:');
  print('  • database_selection_screen.dart');
  print('  • database_screen.dart');
  print('\nBackups creados:');
  print('  • database_selection_screen.dart.backup');
  print('  • database_screen.dart.backup');
  print('\n✓ Listo para probar!');
  print('\nSi algo sale mal, puedes restaurar con:');
  print('  copy "$selectionScreenPath.backup" "$selectionScreenPath"');
  print('  copy "$databaseScreenPath.backup" "$databaseScreenPath"');
}
