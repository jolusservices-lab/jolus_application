import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/colors.dart';
import '../widgets/category_carousel.dart';
import '../widgets/service_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JolusColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 0,
            leading: const Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: JolusColors.surfaceLow,
                child: Icon(Icons.person, color: JolusColors.primary, size: 20),
              ),
            ),
            title: Text(
              'Jolus Services',
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.bold,
                color: JolusColors.primary,
                fontSize: 18,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_outlined, color: JolusColors.primary),
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                TextField(
                  decoration: InputDecoration(
                    hintText: '¿Qué servicio necesitas hoy?',
                    hintStyle: GoogleFonts.inter(color: Colors.grey[400], fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
                const SizedBox(height: 24),

                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF0D1B3E), Color(0xFF1E3A8A)],
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'OFERTA EXCLUSIVA',
                        style: TextStyle(
                          color: Colors.white70,
                          letterSpacing: 1.2,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '20% Off en Buffet Premium',
                        style: GoogleFonts.manrope(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Válido para eventos este fin de semana',
                        style: TextStyle(color: Colors.white60, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Categorías',
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: JolusColors.onSurfaceVariant,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Ver todas',
                        style: GoogleFonts.inter(
                          color: JolusColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                const CategoryCarousel(),

                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Servicios Destacados',
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: JolusColors.onSurfaceVariant,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Explorar',
                        style: GoogleFonts.inter(
                          color: JolusColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                const ServiceCard(
                  id: 's1',
                  title: 'Buffet Ejecutivo Premium',
                  price: 45.0,
                  unit: '/pp',
                  description: 'Servicio completo para eventos corporativos con opciones gourmet...',
                  rating: '4.9',
                  footerIcon: Icons.access_time,
                  footerText: 'Min. 3h',
                  imageUrl: 'https://images.unsplash.com/photo-1555244162-803834f70033?q=80&w=800',
                ),
                const SizedBox(height: 16),
                const ServiceCard(
                  id: 's2',
                  title: 'Barra Móvil de Cócteles',
                  price: 280.0,
                  unit: '/evento',
                  description: 'Mixología creativa para bodas y fiestas privadas. Incluye insumos y barra...',
                  rating: '4.8',
                  footerIcon: Icons.people_outline,
                  footerText: 'Hasta 50 pers.',
                  imageUrl: 'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?q=80&w=800',
                ),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
