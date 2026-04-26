import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/services/database_service.dart';
import '../../core/models/service_model.dart';
import '../../core/providers/navigation_provider.dart';
import '../widgets/filter_chip.dart';
import '../widgets/service_detail_card.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final DatabaseService _dbService = DatabaseService();

  final List<String> _servicesList = [
    'Todos',
    'Decoraciones',
    'Buffet',
    'Coctelería',
    'Animaciones',
    'Entretenimiento',
    'Mobiliario'
  ];

  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<NavigationProvider>();
    final selectedService = navProvider.selectedCategory;

    return Scaffold(
      backgroundColor: JolusColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              'Jolus Services',
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.bold,
                color: JolusColors.primary,
                fontSize: 18,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  'Catálogo de Servicios',
                  style: GoogleFonts.manrope(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF00236F),
                  ),
                ),
                const SizedBox(height: 24),
                // Chips de Servicio (Decoraciones, Buffet, etc.)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _servicesList.map((service) {
                      return GestureDetector(
                        onTap: () => navProvider.setCategory(service),
                        child: FilterChipWidget(
                          label: service,
                          isSelected: selectedService == service,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 32),
                // Lista de Productos desde Supabase
                FutureBuilder<List<ServiceModel>>(
                  future: _dbService.getProducts(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40.0),
                          child: CircularProgressIndicator(color: JolusColors.primary),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final allProducts = snapshot.data ?? [];
                    final filteredProducts = selectedService == 'Todos'
                        ? allProducts
                        : allProducts.where((p) => 
                            p.servicio.toLowerCase() == selectedService.toLowerCase()
                          ).toList();

                    if (filteredProducts.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Text('No hay productos disponibles en esta sección.', 
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(color: Colors.grey)),
                        ),
                      );
                    }

                    return Column(
                      children: filteredProducts.map((product) => Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: ServiceDetailCard(
                          service: product,
                        ),
                      )).toList(),
                    );
                  },
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
