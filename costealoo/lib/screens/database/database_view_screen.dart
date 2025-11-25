import 'package:flutter/material.dart';
import 'package:costealoo/theme/costealo_theme.dart';
import 'package:costealoo/widgets/sidebar_menu.dart';
import 'package:costealoo/services/database_service.dart';
// import 'package:costealoo/services/api_client.dart'; // Unused for now

class DatabaseViewScreen extends StatefulWidget {
  final String databaseId; // Added ID to identify the database
  final String databaseName;
  final List<Map<String, dynamic>> products;

  const DatabaseViewScreen({
    super.key,
    this.databaseId = '', // Optional for now to support legacy calls
    required this.databaseName,
    this.products = const [],
  });

  @override
  State<DatabaseViewScreen> createState() => _DatabaseViewScreenState();
}

class _DatabaseViewScreenState extends State<DatabaseViewScreen> {
  late String _currentName;

  @override
  void initState() {
    super.initState();
    _currentName = widget.databaseName;
  }

  Future<void> _renameDatabase() async {
    final controller = TextEditingController(text: _currentName);

    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Renombrar base de datos'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nuevo nombre',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty && newName != _currentName) {
      try {
        // Call service to update
        // Note: We need the ID. If not provided, we can't update on backend/mock properly
        // For now, we'll assume we can update if we have an ID, or just update UI if not.
        if (widget.databaseId.isNotEmpty) {
          await DatabaseService().updateDatabase(
            id: widget.databaseId,
            name: newName,
          );
        }

        setState(() {
          _currentName = newName;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nombre actualizado'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al actualizar nombre'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
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
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () =>
                            Navigator.pop(context, {'newName': _currentName}),
                        tooltip: 'Regresar',
                      ),
                      const SizedBox(width: 8),
                      Text(_currentName, style: textTheme.headlineSmall),
                      const SizedBox(width: 8),
                      // Edit Name Icon
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: _renameDatabase,
                        tooltip: 'Renombrar',
                        color: Colors.grey[700],
                      ),
                      const Spacer(),
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
                            color: Colors.black.withValues(alpha: 0.05),
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
                            decoration: const BoxDecoration(
                              color: CostealoColors.cardSoft,
                              borderRadius: BorderRadius.only(
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
                            child: widget.products.isEmpty
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
                                      itemCount: widget.products.length,
                                      itemBuilder: (context, index) {
                                        final product = widget.products[index];
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

  Widget _buildProductRow(Map<String, dynamic> product) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          _buildCell(product['id']?.toString() ?? '', flex: 1),
          _buildCell(product['name']?.toString() ?? '', flex: 3),
          _buildCell(product['price']?.toString() ?? '', flex: 2),
          _buildCell(product['unit']?.toString() ?? '', flex: 2),
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
}
