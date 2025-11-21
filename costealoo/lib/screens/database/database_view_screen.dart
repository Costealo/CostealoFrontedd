import 'package:flutter/material.dart';
import 'package:costealoo/theme/costealo_theme.dart';
import 'package:costealoo/widgets/sidebar_menu.dart';

import 'package:costealoo/services/auth_service.dart';

class DatabaseViewScreen extends StatelessWidget {
  final String databaseName;
  final List<Map<String, String>> products;

  const DatabaseViewScreen({
    super.key,
    required this.databaseName,
    this.products = const [],
  });

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
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                        tooltip: 'Regresar',
                      ),
                      const SizedBox(width: 8),
                      Text(databaseName, style: textTheme.headlineSmall),
                      const Spacer(),
                      if (AuthService().currentUser?.organizacion == 'Empresa')
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            // TODO: Navegar a edición
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Edición próximamente'),
                              ),
                            );
                          },
                          tooltip: 'Editar',
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Tabla de visualización
                  Expanded(
                    child: Container(
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
                      child: Column(
                        children: [
                          // Header de la tabla
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: CostealoColors.cardSoft,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                            ),
                            child: Row(
                              children: [
                                _buildHeaderCell('ID', flex: 1),
                                _buildHeaderCell('Nombre producto', flex: 3),
                                _buildHeaderCell('Precio', flex: 2),
                                _buildHeaderCell('Unidad de medida', flex: 2),
                              ],
                            ),
                          ),

                          // Contenido de la tabla
                          Expanded(
                            child: products.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.table_chart_outlined,
                                          size: 64,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Esta base de datos está vacía',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Scrollbar(
                                    thumbVisibility: true,
                                    child: ListView.builder(
                                      itemCount: products.length,
                                      itemBuilder: (context, index) {
                                        final product = products[index];
                                        return _buildProductRow(product);
                                      },
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Botones inferiores - Solo para Empresas
                  if (AuthService().currentUser?.organizacion == 'Empresa')
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Botón Eliminar
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[50],
                            foregroundColor: Colors.red[700],
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            _showDeleteConfirmation(context);
                          },
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Eliminar'),
                        ),

                        // Botón Editar
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CostealoColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            // TODO: Navegar a edición
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Edición próximamente'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Editar'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }

  Widget _buildProductRow(Map<String, String> product) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          _buildCell(product['id'] ?? '', flex: 1),
          _buildCell(product['name'] ?? '', flex: 3),
          _buildCell(product['price'] ?? '', flex: 2),
          _buildCell(product['unit'] ?? '', flex: 2),
        ],
      ),
    );
  }

  Widget _buildCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(text, style: const TextStyle(fontSize: 13)),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar base de datos'),
          content: Text(
            '¿Estás seguro de que deseas eliminar "$databaseName"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context); // Cerrar diálogo
                Navigator.pop(context, {'deleted': true}); // Regresar
                // TODO: Eliminar de API
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }
}
