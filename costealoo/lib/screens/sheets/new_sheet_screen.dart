import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:costealoo/theme/costealo_theme.dart';
import 'package:costealoo/widgets/sidebar_menu.dart';
import 'package:costealoo/services/database_service.dart';
import 'package:costealoo/services/api_client.dart';

class NewSheetScreen extends StatefulWidget {
  final List<Map<String, dynamic>>? preLoadedProducts;

  const NewSheetScreen({super.key, this.preLoadedProducts});

  @override
  State<NewSheetScreen> createState() => _NewSheetScreenState();
}

class _NewSheetScreenState extends State<NewSheetScreen> {
  // Ingredientes
  final List<TextEditingController> _ingredientNames = [];
  final List<TextEditingController> _ingredientQuantities = [];

  // Costos adicionales
  final List<TextEditingController> _extraNames = [];
  final List<TextEditingController> _extraQuantities = [];

  // Totales y datos generales (por ahora solo UI)
  final TextEditingController _totalController = TextEditingController(
    text: '0,00',
  );
  final TextEditingController _pesoTotalController = TextEditingController(
    text: '0,00',
  );
  final TextEditingController _pesoUnitarioController = TextEditingController(
    text: '0,00',
  );
  final TextEditingController _cantidadRacionController =
      TextEditingController();
  final TextEditingController _totalFinalController = TextEditingController(
    text: '0,00',
  );

  // Nuevos controladores para los cálculos
  final TextEditingController _operatingCostsController = TextEditingController(
    text: '0,00',
  );
  final TextEditingController _netCostController = TextEditingController(
    text: '0,00',
  );
  final TextEditingController _taxController = TextEditingController(
    text: '0,00',
  );
  final TextEditingController _totalCostController = TextEditingController(
    text: '0,00',
  );
  final TextEditingController _unitCostController = TextEditingController(
    text: '0,00',
  );
  final TextEditingController _suggestedPriceController = TextEditingController(
    text: '0,00',
  );
  final TextEditingController _salePriceController = TextEditingController(
    text: '0,00',
  );
  final TextEditingController _marginController = TextEditingController(
    text: '0,00 %',
  );

  String _currency = 'Bs';

  @override
  void initState() {
    super.initState();
    _addIngredientRow();
    _addExtraCostRow();

    // Listeners para recálculos
    _cantidadRacionController.addListener(_calculateValues);
    _salePriceController.addListener(_calculateMargin);
  }

  void _calculateValues() {
    double totalIngredients = 0.0;
    double totalExtras = 0.0;

    // Sumar ingredientes
    for (int i = 0; i < _ingredientQuantities.length; i++) {
      // Asumimos que el costo ya está en el campo de cantidad por ahora
      // O mejor, necesitamos un campo de costo unitario por ingrediente.
      // PERO el mockup muestra: Nombre | Cantidad (xx,xx) | Total ($$$,$$)
      // El mockup es un poco confuso. Dice "Cantidad" y luego "Total".
      // Asumiremos que el usuario ingresa el COSTO TOTAL del ingrediente por ahora,
      // o que la cantidad * precio_base = total.
      // Dado el mockup, parece que "Cantidad" es el costo directo si no hay precio unitario.
      // REVISIÓN: El mockup tiene "Cantidad" (editable) y al lado "Moneda".
      // Y luego "Total" abajo de la lista.
      // Vamos a asumir que el input es el COSTO del ingrediente para simplificar,
      // o que implementaremos precio * cantidad luego.
      // Por ahora, sumaremos los valores ingresados.

      final val =
          double.tryParse(_ingredientQuantities[i].text.replaceAll(',', '.')) ??
          0.0;
      totalIngredients += val;
    }

    // Sumar extras
    for (int i = 0; i < _extraQuantities.length; i++) {
      final val =
          double.tryParse(_extraQuantities[i].text.replaceAll(',', '.')) ?? 0.0;
      totalExtras += val;
    }

    // 1. Total Ingredientes + Extras
    // Nota: El mockup tiene un "Total" debajo de ingredientes y otro debajo de extras.
    _totalController.text = totalIngredients.toStringAsFixed(2);
    _totalFinalController.text = totalExtras.toStringAsFixed(2);

    // 2. Costos operativos (20%)
    final sumBase = totalIngredients + totalExtras;
    final operatingCosts = sumBase * 0.20;
    _operatingCostsController.text = operatingCosts.toStringAsFixed(2);

    // 3. Costo neto
    final netCost = sumBase + operatingCosts;
    _netCostController.text = netCost.toStringAsFixed(2);

    // 4. Impuestos (16%)
    final tax = netCost * 0.16;
    _taxController.text = tax.toStringAsFixed(2);

    // 5. Costo total
    final totalCost = netCost + tax; // o netCost * 1.16
    _totalCostController.text = totalCost.toStringAsFixed(2);

    // 6. Costo unitario
    final rationQty =
        double.tryParse(_cantidadRacionController.text.replaceAll(',', '.')) ??
        1.0;
    final unitCost = rationQty > 0 ? totalCost / rationQty : 0.0;
    _unitCostController.text = unitCost.toStringAsFixed(2);

    // 7. Precio sugerido (Costo unitario + 20%)
    final suggestedPrice = unitCost * 1.20;
    _suggestedPriceController.text = suggestedPrice.toStringAsFixed(2);

    // Recalcular margen si hay precio de venta
    _calculateMargin();
  }

  void _calculateMargin() {
    final salePrice =
        double.tryParse(_salePriceController.text.replaceAll(',', '.')) ?? 0.0;
    final unitCost =
        double.tryParse(_unitCostController.text.replaceAll(',', '.')) ?? 0.0;

    if (salePrice > 0) {
      final margin = ((salePrice - unitCost) / salePrice) * 100;
      _marginController.text = '${margin.toStringAsFixed(2)} %';
    } else {
      _marginController.text = '0,00 %';
    }
  }

  @override
  void dispose() {
    for (final c in _ingredientNames) {
      c.dispose();
    }
    for (final c in _ingredientQuantities) {
      c.dispose();
    }
    for (final c in _extraNames) {
      c.dispose();
    }
    for (final c in _extraQuantities) {
      c.dispose();
    }
    _totalController.dispose();
    _pesoTotalController.dispose();
    _pesoUnitarioController.dispose();
    _cantidadRacionController.dispose();
    _totalFinalController.dispose();
    _operatingCostsController.dispose();
    _netCostController.dispose();
    _taxController.dispose();
    _totalCostController.dispose();
    _unitCostController.dispose();
    _suggestedPriceController.dispose();
    _salePriceController.dispose();
    _marginController.dispose();
    super.dispose();
  }

  void _addIngredientRow() {
    setState(() {
      final nameCtrl = TextEditingController();
      final qtyCtrl = TextEditingController();
      qtyCtrl.addListener(_calculateValues); // Escuchar cambios
      _ingredientNames.add(nameCtrl);
      _ingredientQuantities.add(qtyCtrl);
    });
  }

  void _addExtraCostRow() {
    setState(() {
      final nameCtrl = TextEditingController();
      final qtyCtrl = TextEditingController();
      qtyCtrl.addListener(_calculateValues); // Escuchar cambios
      _extraNames.add(nameCtrl);
      _extraQuantities.add(qtyCtrl);
    });
  }

  // Sólo formato decimal 2 decimales
  List<TextInputFormatter> get _decimalFormatters => [
    FilteringTextInputFormatter.allow(RegExp(r'^\d*\,?\d{0,2}')),
  ];

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
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(28.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nueva planilla',
                            style: textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // IZQUIERDA: ingredientes + totales
                                Expanded(
                                  flex: 3,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Lista de ingredientes:',
                                          style: textTheme.bodyMedium!.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        _buildIngredientList(context),
                                        const SizedBox(height: 24),

                                        _buildEditableDecimalField(
                                          label: 'Total',
                                          controller: _totalController,
                                        ),
                                        const SizedBox(height: 14),
                                        _buildEditableDecimalField(
                                          label: 'Peso total',
                                          controller: _pesoTotalController,
                                        ),
                                        const SizedBox(height: 14),
                                        _buildEditableDecimalField(
                                          label: 'Peso unitario',
                                          controller: _pesoUnitarioController,
                                        ),
                                        const SizedBox(height: 14),
                                        _buildEditableDecimalField(
                                          label: 'Cantidad de ración',
                                          controller: _cantidadRacionController,
                                        ),
                                        const SizedBox(height: 28),

                                        Text(
                                          'Costos adicionales:',
                                          style: textTheme.bodyMedium!.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        _buildExtraCostList(context),
                                        const SizedBox(height: 24),

                                        _buildReadOnlyField(
                                          label: 'Total',
                                          controller: _totalFinalController,
                                        ),
                                        const SizedBox(height: 28),

                                        // ─────────────────────────────────────
                                        // CÁLCULOS FINALES
                                        // ─────────────────────────────────────
                                        _buildReadOnlyField(
                                          label: 'Costos operativos (20%)',
                                          controller: _operatingCostsController,
                                        ),
                                        const SizedBox(height: 14),
                                        _buildReadOnlyField(
                                          label: 'Costo neto',
                                          controller: _netCostController,
                                        ),
                                        const SizedBox(height: 14),
                                        _buildReadOnlyField(
                                          label: 'Costo impuestos (16%)',
                                          controller: _taxController,
                                        ),
                                        const SizedBox(height: 14),
                                        _buildReadOnlyField(
                                          label: 'Costo total',
                                          controller: _totalCostController,
                                        ),
                                        const SizedBox(height: 14),
                                        _buildReadOnlyField(
                                          label: 'Costo unitario',
                                          controller: _unitCostController,
                                        ),
                                        const SizedBox(height: 28),

                                        _buildReadOnlyField(
                                          label: 'Margen de ganancias',
                                          controller: _marginController,
                                        ),
                                        const SizedBox(height: 14),
                                        _buildReadOnlyField(
                                          label: 'Precio de venta sugerido',
                                          controller: _suggestedPriceController,
                                        ),
                                        const SizedBox(height: 14),
                                        _buildEditableDecimalField(
                                          label: 'Precio de venta',
                                          controller: _salePriceController,
                                        ),
                                        const SizedBox(height: 40),

                                        // Botones de acción
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            OutlinedButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text('Cancelar'),
                                            ),
                                            const SizedBox(width: 16),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    CostealoColors.primary,
                                                foregroundColor: Colors.white,
                                              ),
                                              onPressed: () {
                                                // Guardar lógica
                                              },
                                              child: const Text('Publicar'),
                                            ),
                                            const SizedBox(width: 16),
                                            OutlinedButton(
                                              onPressed: () {},
                                              child: const Text(
                                                'Guardar borrador',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 24),

                                // DERECHA: cantidad (columna) + moneda
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        'Cantidad',
                                        style: textTheme.bodyMedium!.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                            color: CostealoColors.cardSoft,
                                          ),
                                          alignment: Alignment.topCenter,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          child: Text(
                                            'Los campos de cantidad\n'
                                            'admiten 2 decimales.',
                                            textAlign: TextAlign.center,
                                            style: textTheme.bodySmall!
                                                .copyWith(
                                                  color: Colors.grey[700],
                                                ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Text(
                                        'Moneda:',
                                        style: textTheme.bodyMedium!.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ToggleButtons(
                                        isSelected: [
                                          _currency == 'Bs',
                                          _currency == 'USD',
                                        ],
                                        onPressed: (index) {
                                          setState(() {
                                            _currency = index == 0
                                                ? 'Bs'
                                                : 'USD';
                                          });
                                        },
                                        borderRadius: BorderRadius.circular(20),
                                        children: const [
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                            child: Text('Bs'),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                            child: Text('\$us'),
                                          ),
                                        ],
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────── UI helpers ─────────────────

  Widget _buildIngredientList(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        for (int i = 0; i < _ingredientNames.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                // Nombre ingrediente
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _ingredientNames[i],
                    decoration: InputDecoration(
                      hintText: 'Ingrediente ${i + 1}',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          _showProductSelectionDialog(
                            i,
                            _ingredientNames,
                            _ingredientQuantities,
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Cantidad
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _ingredientQuantities[i],
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: _decimalFormatters,
                    decoration: const InputDecoration(hintText: 'xx,xx'),
                  ),
                ),
              ],
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _addIngredientRow,
            icon: const Icon(Icons.add),
            label: Text('Agregar ingrediente', style: textTheme.bodyMedium),
          ),
        ),
      ],
    );
  }

  Widget _buildExtraCostList(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        for (int i = 0; i < _extraNames.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _extraNames[i],
                    decoration: InputDecoration(
                      hintText: 'Costo ${i + 1}',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          // luego conectamos con base de datos si aplica
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _extraQuantities[i],
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: _decimalFormatters,
                    decoration: const InputDecoration(hintText: 'xx,xx'),
                  ),
                ),
              ],
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _addExtraCostRow,
            icon: const Icon(Icons.add),
            label: Text('Agregar costo adicional', style: textTheme.bodyMedium),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required TextEditingController controller,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: TextField(controller: controller, readOnly: true),
        ),
      ],
    );
  }

  Widget _buildEditableDecimalField({
    required String label,
    required TextEditingController controller,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: _decimalFormatters,
          ),
        ),
      ],
    );
  }

  Future<void> _showProductSelectionDialog(
    int index,
    List<TextEditingController> nameControllers,
    List<TextEditingController> qtyControllers,
  ) async {
    try {
      List<Map<String, dynamic>> allProducts = [];

      if (widget.preLoadedProducts != null &&
          widget.preLoadedProducts!.isNotEmpty) {
        allProducts = widget.preLoadedProducts!;
      } else {
        // Obtener todas las bases de datos
        final databases = await DatabaseService().getDatabases();
        for (var db in databases) {
          final products = (db['products'] as List?)?.cast<Map>() ?? [];
          for (var prod in products) {
            final p = Map<String, dynamic>.from(prod);
            p['source_db'] = db['name']; // Añadir nombre de la BD para contexto
            allProducts.add(p);
          }
        }
      }

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) {
          String searchQuery = '';
          return StatefulBuilder(
            builder: (context, setState) {
              final filteredProducts = allProducts.where((prod) {
                final name = prod['name']?.toString().toLowerCase() ?? '';
                return name.contains(searchQuery.toLowerCase());
              }).toList();

              return AlertDialog(
                title: const Text('Buscar producto'),
                content: SizedBox(
                  width: double.maxFinite,
                  height: 400,
                  child: Column(
                    children: [
                      TextField(
                        decoration: const InputDecoration(
                          hintText: 'Buscar...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: filteredProducts.isEmpty
                            ? const Center(
                                child: Text('No se encontraron productos'),
                              )
                            : ListView.separated(
                                itemCount: filteredProducts.length,
                                separatorBuilder: (ctx, i) => const Divider(),
                                itemBuilder: (context, i) {
                                  final prod = filteredProducts[i];
                                  final source = prod['source_db'] != null
                                      ? ' • ${prod['source_db']}'
                                      : '';
                                  return ListTile(
                                    title: Text(
                                      prod['name'] ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Precio: ${prod['price'] ?? '0.00'} ${prod['unit'] ?? ''}$source',
                                    ),
                                    onTap: () {
                                      _selectProduct(
                                        prod,
                                        index,
                                        nameControllers,
                                        qtyControllers,
                                      );
                                      Navigator.pop(context);
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cerrar'),
                  ),
                ],
              );
            },
          );
        },
      );
    } on ApiException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar productos'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _selectProduct(
    Map<dynamic, dynamic> prod,
    int index,
    List<TextEditingController> nameControllers,
    List<TextEditingController> qtyControllers,
  ) {
    nameControllers[index].text = prod['name'] ?? '';
    if (prod['price'] != null) {
      qtyControllers[index].text = prod['price'].toString();
      // Disparar recálculo
      _calculateValues();
    }
  }
}
