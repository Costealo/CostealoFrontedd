import 'package:flutter/material.dart';
import 'package:costealoo/routes/app_routes.dart';
import 'package:costealoo/theme/costealo_theme.dart';

class SidebarMenu extends StatelessWidget {
  const SidebarMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      color: CostealoColors.primaryDark,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Parte superior
          Column(
            children: [
              const SizedBox(height: 24),
              _SidebarIconButton(
                icon: Icons.person_outline,
                tooltip: 'Usuario',
                onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
              ),
              const SizedBox(height: 24),
              _SidebarIconButton(
                icon: Icons.add,
                tooltip: 'Nueva planilla',
                onTap: () => Navigator.pushNamed(context, AppRoutes.newSheet),
              ),
              const SizedBox(height: 24),
              _SidebarIconButton(
                icon: Icons.bar_chart_outlined,
                tooltip: 'Resumen de precios',
                onTap: () => Navigator.pushNamed(context, AppRoutes.summary),
              ),
              const SizedBox(height: 24),
              _SidebarIconButton(
                icon: Icons.table_rows_outlined,
                tooltip: 'Base de datos',
                onTap: () => Navigator.pushNamed(context, AppRoutes.database),
              ),
            ],
          ),

          // Parte inferior: cerrar sesión
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: _SidebarIconButton(
              icon: Icons.logout,
              tooltip: 'Cerrar sesión',
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.welcome,
                  (route) => false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _SidebarIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            icon,
            color: Colors.white,
            size: 26,
          ),
        ),
      ),
    );
  }
}
