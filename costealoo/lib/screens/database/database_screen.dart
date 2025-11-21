import 'package:flutter/material.dart';
import 'package:costealoo/theme/costealo_theme.dart';
import 'package:costealoo/widgets/sidebar_menu.dart';

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
      "extra": "-"
    },
    {
      "id": 2,
      "name": "Huevos",
      "price": 0.90,
      "unit": "unidad",
      "currency": "Bs",
      "extra": "-"
    },
    {
      "id": 3,
      "name": "Aceite",
      "price": 12.50,
      "unit": "L",
      "currency": "Bs",
      "extra": "-"
    },
  ];

  Future<void> refreshDatabase() async {
    setState(() {});
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
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Base de datos",
                    style: textTheme.headlineMedium,
                  ),

                  const SizedBox(height: 24),

                  // TABLA
                  Expanded(
                    child: Container(
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
                      child: Scrollbar(
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: DataTable(
                            headingRowColor: MaterialStateProperty.all(
                              CostealoColors.cardSoft,
                            ),
                            columns: const [
                              DataColumn(label: Text("ID")),
                              DataColumn(label: Text("Nombre producto")),
                              DataColumn(label: Text("Precio")),
                              DataColumn(label: Text("Unidad de medida")),
                              DataColumn(label: Text("Moneda")),
                              DataColumn(label: Text("Otros campos")),
                            ],
                            rows: productDatabase.map((item) {
                              return DataRow(cells: [
                                DataCell(Text(item["id"].toString())),
                                DataCell(Text(item["name"])),
                                DataCell(Text(
                                    item["price"].toStringAsFixed(2))),
                                DataCell(Text(item["unit"])),
                                DataCell(Text(item["currency"])),
                                DataCell(Text(item["extra"])),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // BOTONES
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
