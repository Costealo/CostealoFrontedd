#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script para implementar la funcionalidad de importación de Excel
Modifica database_selection_screen.dart y database_screen.dart
"""

import os
import re
import shutil

print("=== Implementando funcionalidad de importación de Excel ===\n")

# Rutas
project_path = r"c:\costealo\CostealoFrontedd-1\costealoo"
selection_screen_path = os.path.join(project_path, r"lib\screens\database\database_selection_screen.dart")
database_screen_path = os.path.join(project_path, r"lib\screens\database\database_screen.dart")

# 1. Crear backups
print("1. Creando backups...")
shutil.copy2(selection_screen_path, selection_screen_path + ".backup")
shutil.copy2(database_screen_path, database_screen_path + ".backup")
print("   ✓ Backups creados\n")

# ===== MODIFICAR database_selection_screen.dart =====
print("2. Modificando database_selection_screen.dart...")

with open(selection_screen_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 2.1 Agregar import
import_line = "import 'package:costealoo/utils/excel_import_helper.dart';"
if import_line not in content:
    content = content.replace(
       "import 'package:costealoo/screens/sheets/new_sheet_screen.dart';",
        "import 'package:costealoo/screens/sheets/new_sheet_screen.dart';\r\n" + import_line
    )
    print("   ✓ Import agregado")
else:
    print("   - Import ya existe")

# 2.2 Agregar método _importFromExcel
method_to_add = """
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
"""

if "_importFromExcel" not in content:
    # Encontrar el final del método _createSheetFromDatabase
    pattern = r"(  void _createSheetFromDatabase\(Map<String, dynamic> database\) \{[^\}]*\}[^\}]*\}[\r\n]+)"
    content = re.sub(pattern, r"\1" + method_to_add + "\r\n", content, count=1)
    print("   ✓ Método _importFromExcel agregado")
else:
    print("   - Método _importFromExcel ya existe")

# 2.3 Cambiar comentario del botón
content = content.replace("// Botón Exportar de archivo", "// Botón Importar archivo")

# 2.4 Cambiar onPressed y label del botón
old_button_code = """onPressed: () {
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
                          label: const Text('Exportar de archivo'),"""

new_button_code = """onPressed: _importFromExcel,
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Importar archivo'),"""

content = content.replace(old_button_code, new_button_code)
print("   ✓ Botón actualizado")

# Guardar cambios
with open(selection_screen_path, 'w', encoding='utf-8') as f:
    f.write(content)

# ===== MODIFICAR database_screen.dart =====
print("\n3. Modificando database_screen.dart...")

with open(database_screen_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 3.1 Modificar constructor
old_constructor = """class DatabaseScreen extends StatefulWidget {
  final String initialName;

  const DatabaseScreen({super.key, this.initialName = 'Nueva Base de Datos'});"""

new_constructor = """class DatabaseScreen extends StatefulWidget {
  final String initialName;
  final List<Map<String, dynamic>>? preLoadedProducts;

  const DatabaseScreen({
    super.key,
    this.initialName = 'Nueva Base de Datos',
    this.preLoadedProducts,
  });"""

content = content.replace(old_constructor, new_constructor)
print("   ✓ Constructor modificado")

# 3.2 Modificar initState
old_init_state = """  @override
  void initState() {
    super.initState();
    // Iniciar con 10 filas vacías
    for (int i = 0; i < 10; i++) {
      _addNewRow();
    }
  }"""

new_init_state = """  @override
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
  }"""

content = content.replace(old_init_state, new_init_state)
print("   ✓ initState modificado")

# Guardar cambios
with open(database_screen_path, 'w', encoding='utf-8') as f:
    f.write(content)

# Resumen
print("\n=== Cambios completados exitosamente ===\n")
print("Archivos modificados:")
print("  • database_selection_screen.dart")
print("  • database_screen.dart")
print("\nBackups creados:")
print("  • database_selection_screen.dart.backup")
print("  • database_screen.dart.backup")
print("\n✓ Listo para probar!")
print("\nSi algo sale mal, puedes restaurar con:")
print(f"  copy \"{selection_screen_path}.backup\" \"{selection_screen_path}\"")
print(f"  copy \"{database_screen_path}.backup\" \"{database_screen_path}\"")
