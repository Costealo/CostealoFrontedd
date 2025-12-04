import 'package:flutter/material.dart';
import 'package:costealoo/theme/costealo_theme.dart';
import 'package:costealoo/widgets/sidebar_menu.dart';
import 'package:costealoo/widgets/section_card.dart';
import 'package:costealoo/services/sheet_service.dart';
import 'package:costealoo/screens/sheets/new_sheet_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  List<Map<String, dynamic>> _sheets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSheets();
  }

  Future<void> _loadSheets() async {
    try {
      final sheets = await SheetService().getSheets();
      if (mounted) {
        setState(() {
          _sheets = sheets;
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

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Row(
        children: [
          SidebarMenu(onSheetCreated: _loadSheets),

          // Contenido principal
          Expanded(
            child: Container(
              color: CostealoColors.primaryLight,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Barra superior con buscador
                    Row(
                      children: [
                        Expanded(
                          child: Container(
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
                                    decoration: InputDecoration(
                                      hintText: 'Buscar por nombre de planilla',
                                      border: InputBorder.none,
                                      hintStyle: TextStyle(
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.search,
                                  color: Colors.grey[600],
                                  size: 22,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Contenido scrolleable
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : RefreshIndicator(
                              onRefresh: _loadSheets,
                              child: SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Borradores',
                                      style: textTheme.headlineSmall,
                                    ),
                                    const SizedBox(height: 12),

                                    () {
                                      // Filter drafts (status == 0)
                                      final drafts = _sheets
                                          .where(
                                            (sheet) =>
                                                (sheet['status'] ?? 0) == 0,
                                          )
                                          .toList();

                                      return drafts.isEmpty
                                          ? const Text('No hay borradores')
                                          : Wrap(
                                              spacing: 16,
                                              runSpacing: 16,
                                              children: drafts.map((sheet) {
                                                return GestureDetector(
                                                  onTap: () async {
                                                    await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            NewSheetScreen(
                                                              sheetData: sheet,
                                                            ),
                                                      ),
                                                    );
                                                    await _loadSheets();
                                                  },
                                                  child: SectionCard(
                                                    title:
                                                        sheet['name'] ??
                                                        'Sin nombre',
                                                  ),
                                                );
                                              }).toList(),
                                            );
                                    }(),

                                    const SizedBox(height: 32),

                                    Text(
                                      'Más recientes',
                                      style: textTheme.headlineSmall,
                                    ),
                                    const SizedBox(height: 12),

                                    () {
                                      // Filter published (status == 1)
                                      final published = _sheets
                                          .where(
                                            (sheet) =>
                                                (sheet['status'] ?? 0) == 1,
                                          )
                                          .toList();

                                      return published.isEmpty
                                          ? const Text(
                                              'No hay planillas publicadas',
                                            )
                                          : Wrap(
                                              spacing: 16,
                                              runSpacing: 16,
                                              children: published.map((sheet) {
                                                return GestureDetector(
                                                  onTap: () async {
                                                    await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            NewSheetScreen(
                                                              sheetData: sheet,
                                                            ),
                                                      ),
                                                    );
                                                    await _loadSheets();
                                                  },
                                                  child: SectionCard(
                                                    title:
                                                        sheet['name'] ??
                                                        'Sin nombre',
                                                  ),
                                                );
                                              }).toList(),
                                            );
                                    }(),
                                    const SizedBox(height: 40),
                                  ],
                                ),
                              ),
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
