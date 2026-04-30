import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/models/service_model.dart';
import '../../core/providers/navigation_provider.dart';
import '../../core/providers/user_provider.dart';
import '../widgets/category_carousel.dart';
import '../widgets/service_card.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navProvider = context.read<NavigationProvider>();
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: JolusColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 0,
            toolbarHeight: 70,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Center(
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: JolusColors.surfaceLow,
                  backgroundImage: userProvider.photoUrl != null 
                      ? NetworkImage(userProvider.photoUrl!) 
                      : null,
                  child: userProvider.photoUrl == null 
                      ? const Icon(Icons.person, color: JolusColors.primary, size: 20)
                      : null,
                ),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  userProvider.id.isEmpty ? 'Jolus Services' : 'HOLA, ${userProvider.name} ${userProvider.subname}'.toUpperCase().trim(),
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.bold,
                    color: JolusColors.primary,
                    fontSize: 16,
                  ),
                ),
                Text(
                  userProvider.id.isEmpty ? 'Bienvenido a nuestra plataforma' : '¿Qué servicio necesitas hoy?',
                  style: GoogleFonts.inter(
                    color: JolusColors.onSurfaceVariant.withOpacity(0.6),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                ),
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
                      onPressed: () => navProvider.setCategory('Todos'),
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
                      onPressed: () => navProvider.setSelectedIndex(1),
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

                ServiceCard(
                  service: ServiceModel(
                    id: 'eb7617b3-652a-430c-87d4-e696f9260641',
                    nombre: 'Buffet Ejecutivo Premium',
                    precio: 45.0,
                    descripcion: 'Servicio completo para eventos corporativos con opciones gourmet...',
                    imagen: 'https://images.unsplash.com/photo-1555244162-803834f70033?q=80&w=800',
                    categoria: 'Premium',
                    servicio: 'Buffet',
                    cantidad: 1,
                  ),
                ),
                const SizedBox(height: 16),
                ServiceCard(
                  service: ServiceModel(
                    id: '3c754668-2321-4f93-b1d7-27b03138b71d',
                    nombre: 'Barra Móvil de Cócteles',
                    precio: 280.0,
                    descripcion: 'Mixología creativa para bodas y fiestas privadas. Incluye insumos y barra...',
                    imagen: 'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?q=80&w=800',
                    categoria: 'VIP',
                    servicio: 'Coctelería',
                    cantidad: 1,
                  ),
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
