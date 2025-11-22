import 'package:flutter/material.dart';
import 'package:costealoo/routes/app_routes.dart';
import 'package:costealoo/theme/costealo_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo con la imagen limpia
          Positioned.fill(
            child: Image.asset(
              'assets/images/welcome_bg.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Contenido superpuesto
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 4), // Empujar contenido hacia el centro/abajo

                  // Logo
                  const _CostealoLogo(),
                  
                  const SizedBox(height: 10),

                  // Título COSTEALO
                  Text(
                    'COSTEALO',
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 48,
                      fontWeight: FontWeight.w400, // Serif fonts usually look bold enough
                      color: Colors.black,
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Slogan
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Tu socio para una gestión\nde costos inteligente',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 24,
                        color: Colors.black,
                        height: 1.2,
                      ),
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Botón COMENZAR
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.login);
                      },
                      child: Text(
                        'COMENZAR',
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 22,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// LOGO (C + CHECK)
// ─────────────────────────────────────────────

class _CostealoLogo extends StatelessWidget {
  const _CostealoLogo();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // La "C" negra
          Text(
            'C',
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 100,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              height: 1,
            ),
          ),
          // El check verde superpuesto
          Positioned(
            right: 10,
            bottom: 15,
            child: Icon(
              Icons.check_rounded,
              size: 50,
              color: const Color(0xFF8ECF9B), // Color verde del diseño original (accent)
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(1, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
