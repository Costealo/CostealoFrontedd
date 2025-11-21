import 'package:flutter/material.dart';
import 'package:costealoo/routes/app_routes.dart';
import 'package:costealoo/theme/costealo_theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: CostealoColors.primary, // verde sólido
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const _CostealoLogo(),      // ← logo hecho en código
                const SizedBox(height: 40),

                Text(
                  'Bienvenido/a a',
                  style: textTheme.bodyMedium!.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 20,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),

                Text(
                  'Costealo',
                  style: textTheme.headlineLarge!.copyWith(
                    color: Colors.white,
                    fontSize: 56,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1,
                  ),
                ),

                const SizedBox(height: 28),

                Text(
                  'Organice la estructura de costos de su empresa de manera '
                  'profesional y calcule precios de venta que aseguren su margen '
                  'de beneficio. Costealo convierte sus datos en información '
                  'precisa para optimizar la rentabilidad de cada producto.\n\n'
                  'Olvídese de las hojas de cálculo complejas.',
                  style: textTheme.bodyMedium!.copyWith(
                    color: Colors.white.withOpacity(0.95),
                    fontSize: 17,
                    height: 1.45,
                    letterSpacing: 0.2,
                  ),
                ),

                const SizedBox(height: 36),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: CostealoColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.login);
                  },
                  child: const Text(
                    'Comenzar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// LOGO HECHO SOLO CON CÓDIGO (C + CHECK)
// ─────────────────────────────────────────────

class _CostealoLogo extends StatelessWidget {
  const _CostealoLogo();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // círculo con C + check
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.9),
              width: 2,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                'C',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.95),
                  fontSize: 42,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1,
                ),
              ),
              Positioned(
                right: 14,
                bottom: 16,
                child: Icon(
                  Icons.check_rounded,
                  size: 26,
                  color: Colors.white.withOpacity(0.95),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 16),

        Text(
          'Costealo',
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
        ),
      ],
    );
  }
}
