import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/colors.dart';

class HomeHero extends StatelessWidget {
  final VoidCallback onCatalogTap;

  const HomeHero({super.key, required this.onCatalogTap});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: double.infinity,
      height: 480, // Aumentado para dar espacio al logo y contenido
      child: Stack(
        children: [
          // 1. Fondo celeste con curva inferior (Onda de fondo suave)
          Positioned.fill(
            child: ClipPath(
              clipper: HeroBackgroundClipper(),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFF1F7FF),
                      Color(0xFFE7F1FF),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 2. Imagen con forma de Onda (Lado derecho) - Según la referencia
          Positioned(
            top: -20,
            right: -20,
            child: ClipPath(
              clipper: HeroImageWaveClipper(),
              child: Container(
                width: size.width * 0.7,
                height: 420,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage('https://images.unsplash.com/photo-1511795409834-ef04bbd61622?q=80&w=800'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),

          // 2.5 Logo de la Empresa (Posicionado para destacar)
          Positioned(
            top: 0,
            left: 10,
            child: SafeArea(
              child: Image.asset(
                'assets/images/jolus_logo.png',
                height: 200, // Aumentado para máxima visibilidad
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.all_inclusive,
                  color: JolusColors.primaryBlue,
                  size: 40,
                ),
              ),
            ),
          ),

          // 3. Contenido de texto (Izquierda)
          Positioned(
            left: 20,
            top: 220, // Bajado considerablemente para no solaparse con el logo
            child: SizedBox(
              width: size.width * 0.65, // Aumentado ligeramente para mayor margen
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Creamos\nmomentos\n',
                            style: GoogleFonts.manrope(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: JolusColors.primaryDarkBlue,
                              height: 1.1,
                            ),
                          ),
                          TextSpan(
                            text: 'inolvidables',
                            style: GoogleFonts.manrope(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: JolusColors.primaryBlue,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Eventos y decoraciones que inspiran',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: JolusColors.secondaryText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: onCatalogTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: JolusColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 4,
                      shadowColor: JolusColors.primaryBlue.withOpacity(0.3),
                    ),
                    child: Row( // Volvemos a Row pero con minSize y asegurando que quepa
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            'Ver catálogo',
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward, size: 16),
                      ],
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

class HeroBackgroundClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.8);
    
    // Curva inferior suave
    var cp1 = Offset(size.width * 0.25, size.height * 0.95);
    var cp2 = Offset(size.width * 0.75, size.height * 0.65);
    var endPoint = Offset(size.width, size.height * 0.85);
    
    path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, endPoint.dx, endPoint.dy);
    
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class HeroImageWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    // Empezar arriba a la izquierda del contenedor de la imagen
    path.moveTo(size.width * 0.35, 0);
    
    // Curva en forma de S para la imagen según la referencia
    var cp1 = Offset(size.width * -0.15, size.height * 0.45);
    var cp2 = Offset(size.width * 0.5, size.height * 0.75);
    var endPoint = Offset(size.width * 0.15, size.height);
    
    path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, endPoint.dx, endPoint.dy);
    
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
