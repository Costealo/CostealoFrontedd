import 'package:flutter/material.dart';
import 'package:costealoo/theme/costealo_theme.dart';
import 'package:costealoo/widgets/sidebar_menu.dart';
import 'package:costealoo/services/sheet_service.dart';

// Modelo simple interno para esta pantalla
class _SheetSummary {
  final String name;
  final double currentPrice;
  final double margin; // %

  _SheetSummary({
    required this.name,
    required this.currentPrice,
    required this.margin,
  });
}

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Lista completa (se llenará con datos del backend)
  List<_SheetSummary> _allSheets = [];

  // Lista filtrada para mostrar
  List<_SheetSummary> _filteredSheets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSheets();
  }

  Future<void> _loadSheets() async {
    try {
      final sheetsData = await SheetService().getSheets();

      final List<_SheetSummary> loadedSheets = [];

      for (var data in sheetsData) {
        // Parsear margen (viene como string "42.00 %")
        double marginVal = 0.0;
        if (data['margin'] != null) {
          final marginStr = data['margin']
              .toString()
              .replaceAll('%', '')
              .trim();
          marginVal = double.tryParse(marginStr) ?? 0.0;
        }

        loadedSheets.add(
          _SheetSummary(
            name: data['name'] ?? 'Sin nombre',
            currentPrice: (data['salePrice'] as num?)?.toDouble() ?? 0.0,
            margin: marginVal,
          ),
        );
      }

      if (mounted) {
        setState(() {
          _allSheets = loadedSheets;
          _filteredSheets = loadedSheets;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar planillas: $e')),
        );
      }
    }
  }

  void _filterSheets(String text) {
    setState(() {
      _filteredSheets = _allSheets.where((sheet) {
        return sheet.name.toLowerCase().contains(text.toLowerCase());
      }).toList();
    });
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
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resumen de planillas',
                      style: textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 24),

                    // Barra de búsqueda (solo si hay planillas)
                    if (_allSheets.isNotEmpty)
                      Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                              color: Colors.black.withValues(alpha: 0.05),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onChanged: _filterSheets,
                                decoration: InputDecoration(
                                  hintText: 'Buscar por nombre de producto',
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ),
                            ),
                            Icon(
                              Icons.search,
                              color: Colors.grey.shade600,
                              size: 22,
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Lista de planillas
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _filteredSheets.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_allSheets.isEmpty) ...[
                                    Icon(
                                      Icons.description_outlined,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No tienes planillas creadas',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                      ),
                                    ),
                                  ] else
                                    const Text('No se encontraron resultados'),
                                ],
                              ),
                            )
                          : ListView.separated(
                              itemCount: _filteredSheets.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 32, thickness: 1),
                              itemBuilder: (context, index) {
                                final sheet = _filteredSheets[index];

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      sheet.name,
                                      style: textTheme.titleMedium!.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: CostealoColors.primaryDark,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Precio de venta actual: '
                                          'Bs ${sheet.currentPrice.toStringAsFixed(2)}',
                                          style: textTheme.bodyMedium,
                                        ),
                                        Text(
                                          'Margen de ganancia: '
                                          '${sheet.margin.toStringAsFixed(1)} %',
                                          style: textTheme.bodyMedium!.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: CostealoColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
