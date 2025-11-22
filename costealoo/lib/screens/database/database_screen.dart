import 'package:flutter/material.dart';
import 'package:costealoo/theme/costealo_theme.dart';
import 'package:costealoo/widgets/sidebar_menu.dart';
import 'package:excel/excel.dart';
import 'dart:html' as html;

class DatabaseScreen extends StatefulWidget {
  const DatabaseScreen({super.key});

  @override
  State<DatabaseScreen> createState() => _DatabaseScreenState();
}

class _DatabaseScreenState extends State<DatabaseScreen> {
  // Datos mock (luego se remplaza con API)
  List<Map<String, dynamic>> productDatabase = [
    {
      "id": 1,
      "name": "Harina",
      "price": 15.20,
      "unit": "kg",
      "currency": "Bs",
    },
    {
      "id": 2,
      "name": "Huevos",
      "price": 0.90,
      "unit": "unidad",
      "currency": "Bs",
    },
    {
      "id": 3,
      "name": "Aceite",
      "price": 12.50,
      "unit": "L",
      "currency": "Bs",
    },
  ];

  Future<void> refreshDatabase() async {
    setState(() {});
  }

  void exportTemplate() {
    // Crear un nuevo archivo Excel
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Plantilla'];
    
    // Definir encabezados
    sheetObject.appendRow([
      TextCellValue('ID'),
      TextCellValue('Nombre del Producto'),
      TextCellValue('Precio'),
      TextCellValue('Unidad de Medida'),
      TextCellValue('Moneda'),
    ]);
    
    // Agregar filas vacías con moneda predefinida
    for (int i = 0; i < 15; i++) {
      sheetObject.appendRow([
        TextCellValue(''),
        TextCellValue(''),
        TextCellValue(''),
        TextCellValue(''),
        TextCellValue('Bs'),
      ]);
    }
    
    // Agregar nota al final
    sheetObject.appendRow([]);
    sheetObject.appendRow([
      TextCellValue('Por favor ingrese todos sus precios en el valor equivalente en bolivianos (elimine este mensaje para poder importar esta base de datos)'),
    ]);
    
    // Convertir a bytes
    var fileBytes = excel.save();
    
    // Descargar el archivo
    final blob = html.Blob([fileBytes], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'plantilla_base_datos.xlsx')
      ..click();
    html.Url.revokeObjectUrl(url);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Plantilla exportada exitosamente')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Row(
        children: [
          const SidebarMenu(),

          Expanded(
            child: Container(
              color: CostealoColors.primaryLight,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Base de datos",
                    style: textTheme.headlineMedium,
                  ),

                  const SizedBox(height: 12),

                  // TABLA
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                            color: Colors.black.withOpacity(0.05),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SizedBox(
                          width: double.infinity,
                          child: DataTable(
                            headingRowColor: MaterialStateProperty.all(
                              CostealoColors.cardSoft,
                            ),
                            columnSpacing: 40,
                            columns: const [
                              DataColumn(label: Text("ID")),
                              DataColumn(label: Text("Nombre producto")),
                              DataColumn(label: Text("Precio")),
                              DataColumn(label: Text("Unidad de medida")),
                              DataColumn(label: Text("Moneda")),
                            ],
                            rows: productDatabase.map((item) {
                              return DataRow(cells: [
                                DataCell(Text(item["id"].toString())),
                                DataCell(Text(item["name"])),
                                DataCell(Text(
                                    item["price"].toStringAsFixed(2))),
                                DataCell(Text(item["unit"])),
                                DataCell(Text(item["currency"])),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // BOTONES
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // REGRESAR
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CostealoColors.cardSoft,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 28, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Regresar",
                          style: TextStyle(color: Colors.black87),
                        ),
                      ),
                      
                      const SizedBox(width: 16),

                      // DESCARGAR PLANTILLA
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: CostealoColors.primary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: CostealoColors.primary),
                          ),
                        ),
                        onPressed: exportTemplate,
                        icon: const Icon(Icons.download, size: 20),
                        label: const Text("Descargar plantilla"),
                      ),
                      
                      const SizedBox(width: 12),

                      // ACTUALIZAR
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CostealoColors.primary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 28, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: refreshDatabase,
                        child: const Text(
                          "Actualizar",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
