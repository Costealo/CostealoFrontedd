import 'package:flutter/material.dart';
import 'package:costealoo/theme/costealo_theme.dart';
import 'package:costealoo/widgets/sidebar_menu.dart';
import 'package:costealoo/widgets/section_card.dart';
import 'package:costealoo/screens/database/database_view_screen.dart';
import 'package:costealoo/services/auth_service.dart';
import 'package:costealoo/screens/database/database_screen.dart';
import 'package:costealoo/services/database_service.dart';
import 'package:costealoo/services/api_client.dart';
import 'package:costealoo/screens/sheets/new_sheet_screen.dart';

class DatabaseSelectionScreen extends StatefulWidget {
  const DatabaseSelectionScreen({super.key});

  @override
  State<DatabaseSelectionScreen> createState() =>
      _DatabaseSelectionScreenState();
}

class _DatabaseSelectionScreenState extends State<DatabaseSelectionScreen> {
  // Lista de bases de datos guardadas
  // Lista de bases de datos guardadas (ahora guarda objetos completos)
  // Lista de bases de datos guardadas (ahora guarda objetos completos)
  // Lista de bases de datos guardadas (ahora guarda objetos completos)
  List<Map<String, dynamic>> savedDatabases = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDatabases();
  }

  Future<void> _loadDatabases() async {
    setState(() => _isLoading = true);
    try {
      final databases = await DatabaseService().getDatabases();
      if (mounted) {
        setState(() {
          savedDatabases = databases;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar bases de datos'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Lista de borradores
  List<String> draftDatabases = ['Nombre de base de datos'];

  void _refreshDatabases() {
    _loadDatabases();
  }

  Future<void> _navigateToManualEntry() async {
    // Obtener nombre de la empresa del usuario actual
    // Si es registro reciente, 'nombre' tiene el nombre de la empresa
    // Si es login, por ahora usamos 'Mi Empresa' hasta tener endpoint de perfil
    final user = AuthService().currentUser;
    final companyName = (user?.nombre != null && user!.nombre.isNotEmpty)
        ? user.nombre
        : 'Mi Empresa';

    // Navegar y esperar resultado
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DatabaseScreen(initialName: companyName),
      ),
    );

    // Si se publicó una base de datos, actualizar lista
    if (result != null && result is Map && result['published'] == true) {
      _loadDatabases();
    }
  }

  Future<void> _openDatabase(Map<String, dynamic> database) async {
    // Navegar a la pantalla de visualización
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DatabaseViewScreen(
          databaseId: database['id']?.toString() ?? '',
          databaseName: database['name'] as String,
          products: (database['products'] as List).cast<Map<String, dynamic>>(),
        ),
      ),
    );

    // Si se renombró, actualizar lista
    if (result != null && result is Map && result['newName'] != null) {
      _loadDatabases();
    }
  }

  void _createSheetFromDatabase(Map<String, dynamic> database) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewSheetScreen(
          preLoadedProducts: (database['products'] as List?)
              ?.cast<Map<String, dynamic>>(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Row(
        children: [
          const SidebarMenu(),

          // Contenido principal
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
                    // Título y botón actualizar
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Base de datos',
                              style: textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Todas las bases de datos',
                              style: textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Botón actualizar
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _refreshDatabases,
                          tooltip: 'Actualizar',
                          color: CostealoColors.primaryDark,
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Contenido scrolleable
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Sección Borradores
                                  Text(
                                    'Borradores',
                                    style: textTheme.headlineSmall,
                                  ),
                                  const SizedBox(height: 12),

                                  draftDatabases.isEmpty
                                      ? Text(
                                          'No hay borradores',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        )
                                      : Wrap(
                                          spacing: 16,
                                          runSpacing: 16,
                                          children: draftDatabases
                                              .map(
                                                (name) => SectionCard(
                                                  title: name,
                                                  onTap: () => _openDatabase({
                                                    'name': name,
                                                    'products':
                                                        <
                                                          Map<String, dynamic>
                                                        >[],
                                                  }),
                                                ),
                                              )
                                              .toList(),
                                        ),

                                  const SizedBox(height: 32),

                                  // Sección Más recientes
                                  Text(
                                    'Más recientes',
                                    style: textTheme.headlineSmall,
                                  ),
                                  const SizedBox(height: 12),

                                  savedDatabases.isEmpty
                                      ? Text(
                                          'No hay bases de datos guardadas',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        )
                                      : Wrap(
                                          spacing: 16,
                                          runSpacing: 16,
                                          children: savedDatabases
                                              .map(
                                                (db) => SectionCard(
                                                  title: db['name'] as String,
                                                  onTap: () =>
                                                      _createSheetFromDatabase(
                                                        db,
                                                      ),
                                                  onEdit: () =>
                                                      _openDatabase(db),
                                                ),
                                              )
                                              .toList(),
                                        ),
                                  const SizedBox(height: 40),
                                ],
                              ),
                            ),
                    ),

                    // Botones en la parte inferior
                    Row(
                      children: [
                        // Botón Exportar de archivo
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: CostealoColors.primaryDark,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: CostealoColors.primary),
                            ),
                          ),
                          onPressed: () {
                            // TODO: Implementar importar desde archivo
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Importar desde archivo - Próximamente',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Exportar de archivo'),
                        ),

                        const SizedBox(width: 16),

                        // Botón Rellenar (Manual) - Disponible para todos
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CostealoColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _navigateToManualEntry,
                          icon: const Icon(Icons.edit),
                          label: const Text('Rellenar'),
                        ),
                      ],
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
