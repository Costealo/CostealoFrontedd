import 'package:flutter/material.dart';
import 'package:costealoo/theme/costealo_theme.dart';
import 'package:costealoo/widgets/sidebar_menu.dart';
import 'package:costealoo/widgets/section_card.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

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
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
                                  color: Colors.black.withOpacity(0.05),
                                ),
                              ],
                            ),
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: 'Buscar por nombre de planilla',
                                      border: InputBorder.none,
                                      hintStyle:
                                          TextStyle(color: Colors.grey[500]),
                                    ),
                                  ),
                                ),
                                Icon(Icons.search,
                                    color: Colors.grey[600], size: 22),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Contenido scrolleable
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Borradores',
                              style: textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 12),

                            Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: const [
                                SectionCard(title: 'Nombre planilla'),
                                SectionCard(title: 'Nombre planilla'),
                                SectionCard(title: 'Nombre planilla'),
                                SectionCard(title: 'Nombre planilla'),
                              ],
                            ),

                            const SizedBox(height: 32),

                            Text(
                              'Más recientes',
                              style: textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 12),

                            Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: const [
                                SectionCard(title: 'Nombre planilla'),
                                SectionCard(title: 'Nombre planilla'),
                                SectionCard(title: 'Nombre planilla'),
                              ],
                            ),
                            const SizedBox(height: 40),
                          ],
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
