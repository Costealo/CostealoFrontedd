import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:costealoo/theme/costealo_theme.dart';
import 'package:costealoo/widgets/sidebar_menu.dart';
import 'package:costealoo/services/database_service.dart';
import 'package:costealoo/services/api_client.dart';
import 'package:costealoo/services/sheet_service.dart';

class NewSheetScreen extends StatefulWidget {
  final List<Map<String, dynamic>>? preLoadedProducts;
  final Map<String, dynamic>? sheetData;
  final bool isReadOnly;

  const NewSheetScreen({
    super.key,
    this.preLoadedProducts,
    this.sheetData,
    this.isReadOnly = false,
  });

  @override
  State<NewSheetScreen> createState() => _NewSheetScreenState();
}

class _NewSheetScreenState extends State<NewSheetScreen> {
  // Nombre de la planilla
  final TextEditingController _sheetNameController = TextEditingController();

  // Ingredientes
  final List<TextEditingController> _ingredientNames = [];
  final List<TextEditingController> _ingredientQuantities = [];
  final List<TextEditingController> _ingredientAmounts = [];

  // Costos adicionales
  final List<TextEditingController> _extraNames = [];
  final List<TextEditingController> _extraQuantities = [];
  final List<TextEditingController> _extraAmounts = [];

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
  final TextEditingController _productQuantityController =
      TextEditingController(text: '1');
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
  bool _isPublishing = false;

  @override
  void initState() {
    super.initState();

    if (widget.sheetData != null) {
      _loadSheetData();
    } else {
      _addIngredientRow();
      _addExtraCostRow();
    }

    // Listeners para recálculos
    _cantidadRacionController.addListener(_calculateValues);
    _productQuantityController.addListener(_calculateValues);
    _salePriceController.addListener(_calculateMargin);
  }

  void _loadSheetData() {
    final data = widget.sheetData!;
    _sheetNameController.text = data['name'] ?? '';
    _currency = data['currency'] ?? 'Bs';
    _cantidadRacionController.text = data['rationQty']?.toString() ?? '';
    _productQuantityController.text = data['productQty']?.toString() ?? '1';
    _salePriceController.text = data['salePrice']?.toString() ?? '';

    // Cargar ingredientes
    final ingredients = data['ingredients'] as List<dynamic>? ?? [];
    for (var ing in ingredients) {
      final nameCtrl = TextEditingController(text: ing['name']);
      final qtyCtrl = TextEditingController(text: ing['cost']?.toString());
      final amountCtrl = TextEditingController(text: ing['amount']?.toString());

      if (!widget.isReadOnly) {
        qtyCtrl.addListener(_calculateValues);
        amountCtrl.addListener(_calculateValues);
      }

      _ingredientNames.add(nameCtrl);
      _ingredientQuantities.add(qtyCtrl);
      _ingredientAmounts.add(amountCtrl);
    }

    // Cargar extras
    final extras = data['extras'] as List<dynamic>? ?? [];
    for (var ext in extras) {
      final nameCtrl = TextEditingController(text: ext['name']);
      final qtyCtrl = TextEditingController(text: ext['unitPrice']?.toString());
      final amountCtrl = TextEditingController(text: ext['amount']?.toString());

      if (!widget.isReadOnly) {
        qtyCtrl.addListener(_calculateValues);
        amountCtrl.addListener(_calculateValues);
      }

      _extraNames.add(nameCtrl);
      _extraQuantities.add(qtyCtrl);
      _extraAmounts.add(amountCtrl);
    }

    // Si no hay filas, añadir al menos una vacía (solo si no es readOnly)
    if (!widget.isReadOnly && _ingredientNames.isEmpty) _addIngredientRow();
    if (!widget.isReadOnly && _extraNames.isEmpty) _addExtraCostRow();

    // Calcular valores iniciales
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateValues();
    });
  }

  void _calculateValues() {
    double totalIngredients = 0.0;
    double totalExtras = 0.0;

    // Sumar ingredientes
    for (int i = 0; i < _ingredientQuantities.length; i++) {
      final val =
          double.tryParse(_ingredientQuantities[i].text.replaceAll(',', '.')) ??
          0.0;
      totalIngredients += val;
    }

    // Sumar pesos (cantidades físicas)
    double totalWeight = 0.0;
    for (int i = 0; i < _ingredientAmounts.length; i++) {
      final val =
          double.tryParse(_ingredientAmounts[i].text.replaceAll(',', '.')) ??
          0.0;
      totalWeight += val;
    }
    _pesoTotalController.text = totalWeight.toStringAsFixed(2);

    // Sumar extras (Cantidad * Precio Unitario)
    for (int i = 0; i < _extraQuantities.length; i++) {
      final amount =
          double.tryParse(_extraAmounts[i].text.replaceAll(',', '.')) ?? 0.0;
      final unitPrice =
          double.tryParse(_extraQuantities[i].text.replaceAll(',', '.')) ?? 0.0;
      totalExtras += amount * unitPrice;
    }

    // 1. Total Ingredientes + Extras
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
    final totalCost = netCost + tax;
    _totalCostController.text = totalCost.toStringAsFixed(2);

    // 6. Costo unitario
    final rationQty =
        double.tryParse(_cantidadRacionController.text.replaceAll(',', '.')) ??
        1.0;
    final productQty =
        double.tryParse(_productQuantityController.text.replaceAll(',', '.')) ??
        1.0;

    final unitCost = productQty > 0 ? totalCost / productQty : 0.0;
    _unitCostController.text = unitCost.toStringAsFixed(2);

    // Calcular peso unitario
    final unitWeight = rationQty > 0 ? totalWeight / rationQty : 0.0;
    _pesoUnitarioController.text = unitWeight.toStringAsFixed(2);

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

    if (unitCost > 0) {
      final margin = ((salePrice - unitCost) / unitCost) * 100;
      _marginController.text = '${margin.toStringAsFixed(2)} %';
    } else {
      _marginController.text = '0,00 %';
    }
  }

  Future<void> _publishSheet() async {
    if (_sheetNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingrese un nombre para la planilla'),
        ),
      );
      return;
    }

    setState(() => _isPublishing = true);

    try {
      // Recopilar datos
      final ingredients = <Map<String, dynamic>>[];
      for (int i = 0; i < _ingredientNames.length; i++) {
        if (_ingredientNames[i].text.isNotEmpty) {
          ingredients.add({
            'name': _ingredientNames[i].text,
            'amount':
                double.tryParse(
                  _ingredientAmounts[i].text.replaceAll(',', '.'),
                ) ??
                0.0,
            'cost':
                double.tryParse(
                  _ingredientQuantities[i].text.replaceAll(',', '.'),
                ) ??
                0.0,
          });
        }
      }

      final extras = <Map<String, dynamic>>[];
      for (int i = 0; i < _extraNames.length; i++) {
        if (_extraNames[i].text.isNotEmpty) {
          extras.add({
            'name': _extraNames[i].text,
            'amount':
                double.tryParse(_extraAmounts[i].text.replaceAll(',', '.')) ??
                0.0,
            'unitPrice':
                double.tryParse(
                  _extraQuantities[i].text.replaceAll(',', '.'),
                ) ??
                0.0,
          });
        }
      }

      final sheetData = {
        'name': _sheetNameController.text,
        'currency': _currency,
        'rationQty':
            double.tryParse(
              _cantidadRacionController.text.replaceAll(',', '.'),
            ) ??
            0.0,
        'productQty':
            double.tryParse(
              _productQuantityController.text.replaceAll(',', '.'),
            ) ??
            1.0,
        'salePrice':
            double.tryParse(_salePriceController.text.replaceAll(',', '.')) ??
            0.0,
        'ingredients': ingredients,
        'extras': extras,
        'totalCost':
            double.tryParse(_totalCostController.text.replaceAll(',', '.')) ??
            0.0,
        'unitCost':
            double.tryParse(_unitCostController.text.replaceAll(',', '.')) ??
            0.0,
        'margin': _marginController.text,
      };

      await SheetService().createSheet(sheetData);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Planilla publicada con éxito')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al publicar: $e')));
      }
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  Future<void> _editSheetName() async {
    if (widget.sheetData == null || widget.sheetData!['id'] == null) return;

    final nameController = TextEditingController(
      text: _sheetNameController.text,
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar nombre'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nombre de la planilla',
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
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;

              try {
                await SheetService().updateSheet(widget.sheetData!['id'], {
                  'name': nameController.text.trim(),
                });

                if (mounted) {
                  setState(() {
                    _sheetNameController.text = nameController.text.trim();
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nombre actualizado')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al actualizar: $e')),
                  );
                }
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _sheetNameController.dispose();
    for (final c in _ingredientNames) {
      c.dispose();
    }
    for (final c in _ingredientQuantities) {
      c.dispose();
    }
    for (final c in _ingredientAmounts) {
      c.dispose();
    }
    for (final c in _extraNames) {
      c.dispose();
    }
    for (final c in _extraQuantities) {
      c.dispose();
    }
    for (final c in _extraAmounts) {
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
    _productQuantityController.dispose();
    _suggestedPriceController.dispose();
    _salePriceController.dispose();
    _marginController.dispose();
    super.dispose();
  }

  void _addIngredientRow() {
    setState(() {
      final nameCtrl = TextEditingController();
      final qtyCtrl = TextEditingController();
      final amountCtrl = TextEditingController();
      qtyCtrl.addListener(_calculateValues); // Escuchar cambios
      amountCtrl.addListener(
        _calculateValues,
      ); // Escuchar cambios en cantidad física
      _ingredientNames.add(nameCtrl);
      _ingredientQuantities.add(qtyCtrl);
      _ingredientAmounts.add(amountCtrl);
    });
  }

  void _addExtraCostRow() {
    setState(() {
      final nameCtrl = TextEditingController();
      final qtyCtrl = TextEditingController();
      final amountCtrl = TextEditingController();
      qtyCtrl.addListener(_calculateValues); // Escuchar cambios
      amountCtrl.addListener(_calculateValues);
      _extraNames.add(nameCtrl);
      _extraQuantities.add(qtyCtrl);
      _extraAmounts.add(amountCtrl);
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.isReadOnly
                                    ? 'Detalle de planilla'
                                    : 'Nueva planilla',
                                style: textTheme.headlineMedium,
                              ),
                              if (widget.isReadOnly)
                                TextButton.icon(
                                  onPressed: _editSheetName,
                                  icon: const Icon(Icons.edit),
                                  label: const Text('Editar nombre'),
                                ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Nombre de la planilla
                          TextField(
                            controller: _sheetNameController,
                            readOnly: widget.isReadOnly,
                            decoration: const InputDecoration(
                              labelText: 'Nombre de la planilla',
                              border: OutlineInputBorder(),
                            ),
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
                                          readOnly: true, // Siempre calculado
                                        ),
                                        const SizedBox(height: 14),
                                        _buildEditableDecimalField(
                                          label: 'Cantidad de ración',
                                          controller: _cantidadRacionController,
                                        ),
                                        const SizedBox(height: 14),
                                        _buildReadOnlyField(
                                          label: 'Peso total',
                                          controller: _pesoTotalController,
                                        ),
                                        const SizedBox(height: 14),
                                        _buildReadOnlyField(
                                          label: 'Peso unitario',
                                          controller: _pesoUnitarioController,
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
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildReadOnlyField(
                                                label: 'Costo unitario',
                                                controller: _unitCostController,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: _buildEditableDecimalField(
                                                label: 'Cant. producto',
                                                controller:
                                                    _productQuantityController,
                                              ),
                                            ),
                                          ],
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
                                        if (!widget.isReadOnly)
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
                                                onPressed: _isPublishing
                                                    ? null
                                                    : _publishSheet,
                                                child: _isPublishing
                                                    ? const SizedBox(
                                                        width: 20,
                                                        height: 20,
                                                        child:
                                                            CircularProgressIndicator(
                                                              color:
                                                                  Colors.white,
                                                              strokeWidth: 2,
                                                            ),
                                                      )
                                                    : const Text('Publicar'),
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
                                        onPressed: widget.isReadOnly
                                            ? null
                                            : (index) {
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
                    readOnly: widget.isReadOnly,
                    decoration: InputDecoration(
                      hintText: 'Ingrediente ${i + 1}',
                      suffixIcon: widget.isReadOnly
                          ? null
                          : IconButton(
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
                // Cantidad (Física)
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: _ingredientAmounts[i],
                    readOnly: widget.isReadOnly,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: _decimalFormatters,
                    decoration: const InputDecoration(hintText: 'Cant.'),
                  ),
                ),
                const SizedBox(width: 8),
                // Costo (Monetario)
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: _ingredientQuantities[i],
                    readOnly: widget.isReadOnly,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: _decimalFormatters,
                    decoration: const InputDecoration(hintText: 'Costo'),
                  ),
                ),
              ],
            ),
          ),
        if (!widget.isReadOnly)
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
                    readOnly: widget.isReadOnly,
                    decoration: InputDecoration(
                      hintText: 'Costo ${i + 1}',
                      suffixIcon: widget.isReadOnly
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.search),
                              onPressed: () {
                                _showProductSelectionDialog(
                                  i,
                                  _extraNames,
                                  _extraQuantities,
                                );
                              },
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: _extraAmounts[i],
                    readOnly: widget.isReadOnly,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: _decimalFormatters,
                    decoration: const InputDecoration(hintText: 'Cant.'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: _extraQuantities[i],
                    readOnly: widget.isReadOnly,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: _decimalFormatters,
                    decoration: const InputDecoration(hintText: 'Costo'),
                  ),
                ),
              ],
            ),
          ),
        if (!widget.isReadOnly)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _addExtraCostRow,
              icon: const Icon(Icons.add),
              label: Text(
                'Agregar costo adicional',
                style: textTheme.bodyMedium,
              ),
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
    bool readOnly = false,
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
            readOnly: widget.isReadOnly || readOnly,
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
