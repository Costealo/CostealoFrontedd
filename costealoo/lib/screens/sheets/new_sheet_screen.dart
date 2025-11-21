import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:costealoo/theme/costealo_theme.dart';
import 'package:costealoo/widgets/sidebar_menu.dart';

class NewSheetScreen extends StatefulWidget {
  const NewSheetScreen({super.key});

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

  String _currency = 'Bs';

  @override
  void initState() {
    super.initState();
    _addIngredientRow();
    _addExtraCostRow();
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
    super.dispose();
  }

  void _addIngredientRow() {
    setState(() {
      _ingredientNames.add(TextEditingController());
      _ingredientQuantities.add(TextEditingController());
    });
  }

  void _addExtraCostRow() {
    setState(() {
      _extraNames.add(TextEditingController());
      _extraQuantities.add(TextEditingController());
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
                                        const SizedBox(height: 20),
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
                          // luego conectamos con base de datos
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
}
