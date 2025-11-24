# Script para implementar la funcionalidad de importación de Excel
# Este script modifica database_selection_screen.dart y database_screen.dart

Write-Host "=== Implementando funcionalidad de importación de Excel ===" -ForegroundColor Cyan

$projectPath = "c:\costealo\CostealoFrontedd-1\costealoo"
$selectionScreenPath = "$projectPath\lib\screens\database\database_selection_screen.dart"
$databaseScreenPath = "$projectPath\lib\screens\database\database_screen.dart"

# Backup de archivos originales
Write-Host "`n1. Creando backups..." -ForegroundColor Yellow
Copy-Item $selectionScreenPath "$selectionScreenPath.backup" -Force
Copy-Item $databaseScreenPath "$databaseScreenPath.backup" -Force
Write-Host "   ✓ Backups creados" -ForegroundColor Green

# ===== MODIFICAR database_selection_screen.dart =====
Write-Host "`n2. Modificando database_selection_screen.dart..." -ForegroundColor Yellow

$content = Get-Content $selectionScreenPath -Raw

# 2.1 Agregar import
$importToAdd = "import 'package:costealoo/utils/excel_import_helper.dart';"
if ($content -notmatch [regex]::Escape($importToAdd)) {
    $content = $content -replace "(import 'package:costealoo/screens/sheets/new_sheet_screen\.dart';)", "`$1`r`n$importToAdd"
    Write-Host "   ✓ Import agregado" -ForegroundColor Green
} else {
    Write-Host "   - Import ya existe" -ForegroundColor Gray
}

# 2.2 Agregar método _importFromExcel después de _createSheetFromDatabase
$methodToAdd = @"

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
          content: Text('${'$'}{products.length} productos importados correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al importar archivo: ${'$'}e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
"@

if ($content -notmatch "_importFromExcel") {
    $pattern = "(\s+void _createSheetFromDatabase\(Map<String, dynamic> database\) \{[^\}]+\}\s+)"
    $content = $content -replace $pattern, "`$1$methodToAdd`r`n"
    Write-Host "   ✓ Método _importFromExcel agregado" -ForegroundColor Green
} else {
    Write-Host "   - Método _importFromExcel ya existe" -ForegroundColor Gray  
}

# 2.3 Cambiar comentario del botón
$content = $content -replace "// Botón Exportar de archivo", "// Botón Importar archivo"

# 2.4 Cambiar onPressed del botón
$oldOnPressed = @"
onPressed: \(\) \{
\s+// TODO: Implementar importar desde archivo
\s+ScaffoldMessenger\.of\(context\)\.showSnackBar\(
\s+const SnackBar\(
\s+content: Text\(
\s+'Importar desde archivo - Próximamente',
\s+\),
\s+\),
\s+\);
\s+\}
"@
$content = $content -replace $oldOnPressed, "onPressed: _importFromExcel"

# 2.5 Cambiar label del botón
$content = $content -replace "label: const Text\('Exportar de archivo'\)", "label: const Text('Importar archivo')"

Set-Content $selectionScreenPath -Value $content -NoNewline
Write-Host "   ✓ Botón actualizado" -ForegroundColor Green

# ===== MODIFICAR database_screen.dart =====
Write-Host "`n3. Modificando database_screen.dart..." -ForegroundColor Yellow

$content = Get-Content $databaseScreenPath -Raw

# 3.1 Modificar clase DatabaseScreen para agregar preLoadedProducts
$oldClass = @"
class DatabaseScreen extends StatefulWidget \{
  final String initialName;

  const DatabaseScreen\(\{super\.key, this\.initialName = 'Nueva Base de Datos'\}\);
"@

$newClass = @"
class DatabaseScreen extends StatefulWidget {
  final String initialName;
  final List<Map<String, dynamic>>? preLoadedProducts;

  const DatabaseScreen({
    super.key,
    this.initialName = 'Nueva Base de Datos',
    this.preLoadedProducts,
  });
"@

$content = $content -replace $oldClass, $newClass
Write-Host "   ✓ Constructor modificado" -ForegroundColor Green

# 3.2 Modificar initState
$oldInitState = @"
  @override
  void initState\(\) \{
    super\.initState\(\);
    // Iniciar con 10 filas vacías
    for \(int i = 0; i < 10; i\+\+\) \{
      _addNewRow\(\);
    \}
  \}
"@

$newInitState = @"
  @override
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
  }
"@

$content = $content -replace $oldInitState, $newInitState
Set-Content $databaseScreenPath -Value $content -NoNewline
Write-Host "   ✓ initState modificado" -ForegroundColor Green

# Resumen
Write-Host "`n=== Cambios completados exitosamente ===" -ForegroundColor Cyan
Write-Host "`nArchivos modificados:" -ForegroundColor White
Write-Host "  • database_selection_screen.dart" -ForegroundColor White
Write-Host "  • database_screen.dart" -ForegroundColor White
Write-Host "`nBackups creados:" -ForegroundColor White
Write-Host "  • database_selection_screen.dart.backup" -ForegroundColor White
Write-Host "  • database_screen.dart.backup" -ForegroundColor White
Write-Host "`n✓ Listo para probar!" -ForegroundColor Green
Write-Host "`nSi algo sale mal, puedes restaurar con:" -ForegroundColor Yellow
Write-Host "  Copy-Item `"$selectionScreenPath.backup`" `"$selectionScreenPath`" -Force" -ForegroundColor Gray
Write-Host "  Copy-Item `"$databaseScreenPath.backup`" `"$databaseScreenPath`" -Force" -ForegroundColor Gray
