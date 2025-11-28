import 'package:flutter/material.dart';
import 'package:costealoo/theme/costealo_theme.dart';
import 'package:costealoo/widgets/sidebar_menu.dart';
import 'package:costealoo/services/database_service.dart';
import 'package:costealoo/services/api_client.dart';

class DatabaseScreen extends StatefulWidget {
  final String initialName;
  final List<Map<String, dynamic>>? preLoadedProducts;
  final String? databaseId; // ← FIXED: String instead of int

  const DatabaseScreen({
    super.key,
    this.initialName = 'Nueva Base de Datos',
    this.preLoadedProducts,
    this.databaseId,
  });

  @override
  State<DatabaseScreen> createState() => _DatabaseScreenState();
}

class _DatabaseScreenState extends State<DatabaseScreen> {
  // Lista de productos editables
  List<Map<String, TextEditingController>> productRows = [];
  bool _isLoading = false;

  // ← NUEVO: Controller para nombre editable
  late TextEditingController _nameController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // ← NUEVO: Inicializar controller de nombre
    _nameController = TextEditingController(text: widget.initialName);

    // Si hay productos pre-cargados, cargarlos
    if (widget.preLoadedProducts != null &&
        widget.preLoadedProducts!.isNotEmpty) {
      for (var product in widget.preLoadedProducts!) {
        productRows.add({
          'id': TextEditingController(text: product['id']?.toString() ?? ''),
          'name': TextEditingController(
            text: product['name']?.toString() ?? '',
          ),
          'price': TextEditingController(
            text: product['price']?.toString() ?? '',
          ),
          'unit': TextEditingController(
            text: product['unit']?.toString() ?? '',
          ),
        });
      }
    } else {
      // Iniciar con 10 filas vacías
      for (int i = 0; i < 10; i++) {
        _addNewRow();
      }
    }
  }

  @override
  void dispose() {
    // Limpiar todos los controladores
    _nameController.dispose(); // ← NUEVO
    _scrollController.dispose();
    for (var row in productRows) {
      row['id']?.dispose();
      row['name']?.dispose();
      row['price']?.dispose();
      row['unit']?.dispose();
    }
    super.dispose();
  }

  void _addNewRow() {
    setState(() {
      productRows.add({
        'id': TextEditingController(),
        'name': TextEditingController(),
        'price': TextEditingController(),
        'unit': TextEditingController(),
      });
    });
  }

  void _addMultipleRows() {
    setState(() {
      for (int i = 0; i < 5; i++) {
        _addNewRow();
      }
    });
  }

  Future<void> _publish() async {
    // Validar nombre
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El nombre de la base de datos no puede estar vacío'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Recopilar datos de los productos
    final List<Map<String, dynamic>> products = [];

    for (var row in productRows) {
      // Solo agregar filas que tengan al menos el nombre
      if (row['name']!.text.isNotEmpty) {
        products.add({
          'id': row['id']!.text,
          'name': row['name']!.text,
          'price': row['price']!.text,
          'unit': row['unit']!.text,
        });
      }
    }

    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agrega al menos un producto'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ← NUEVO: Verificar si es edición o creación
      if (widget.databaseId != null) {
        // UPDATE: Actualizar base de datos existente
        await DatabaseService().updateDatabase(
          id: widget.databaseId!,
          name: _nameController.text.trim(),
          products: products,
        );
      } else {
        // CREATE: Crear nueva base de datos
        await DatabaseService().createDatabase(
          name: _nameController.text.trim(),
          products: products,
        );
      }

      if (!mounted) return;

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Base de datos publicada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );

      // Regresar indicando éxito
      Navigator.pop(context, {'published': true});
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
                  // Header con campo de nombre editable
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.databaseId != null
                            ? 'Editar Base de Datos'
                            : 'Nueva Base de Datos',
                        style: textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _nameController,
                        style: textTheme.titleLarge,
                        decoration: InputDecoration(
                          labelText: 'Nombre de la base de datos',
                          hintText: 'Ej: Mi Empresa',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Tabla editable
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
                                const SizedBox(width: 60), // Espacio para botón
                              ],
                            ),
                          ),

                          // Filas editables con scroll
                          Expanded(
                            child: Stack(
                              children: [
                                Scrollbar(
                                  controller: _scrollController,
                                  thumbVisibility: true,
                                  child: ListView.builder(
                                    controller: _scrollController,
                                    itemCount: productRows.length,
                                    itemBuilder: (context, index) {
                                      return _buildEditableRow(index);
                                    },
                                  ),
                                ),

                                // Botón flotante "Aumentar filas"
                                Positioned(
                                  right: 8,
                                  bottom: 16,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      FloatingActionButton.small(
                                        backgroundColor: CostealoColors.primary,
                                        onPressed: _addNewRow,
                                        tooltip: 'Añadir 1 fila',
                                        child: const Icon(
                                          Icons.add,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor:
                                              CostealoColors.primaryDark,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            side: const BorderSide(
                                              color: CostealoColors.primary,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                        ),
                                        onPressed: _addMultipleRows,
                                        child: const Text(
                                          'Aumentar\nfilas',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 11),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Botones inferiores
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Botón Regresar
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CostealoColors.cardSoft,
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Regresar'),
                      ),

                      // Botón Publicar
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CostealoColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isLoading ? null : _publish,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Publicar'),
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

  Widget _buildEditableRow(int index) {
    final row = productRows[index];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          _buildEditableCell(row['id']!, flex: 1),
          _buildEditableCell(row['name']!, flex: 3),
          _buildEditableCell(row['price']!, flex: 2, isNumeric: true),
          _buildEditableCell(row['unit']!, flex: 2),

          // Botón para eliminar fila
          SizedBox(
            width: 60,
            child: IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.grey[400]),
              iconSize: 18,
              onPressed: () {
                setState(() {
                  row['id']?.dispose();
                  row['name']?.dispose();
                  row['price']?.dispose();
                  row['unit']?.dispose();
                  productRows.removeAt(index);
                });
              },
              tooltip: 'Eliminar fila',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableCell(
    TextEditingController controller, {
    int flex = 1,
    bool isNumeric = false,
  }) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: TextField(
          controller: controller,
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 8,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: CostealoColors.primary),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
      ),
    );
  }
}
