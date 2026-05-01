import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../core/theme/colors.dart';
import '../../core/models/service_model.dart';
import '../../core/providers/navigation_provider.dart';
import '../../core/services/database_service.dart';
import '../widgets/home_hero.dart';
import '../widgets/category_item.dart';
import '../widgets/event_card.dart';
import '../widgets/premium_banner.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navProvider = context.read<NavigationProvider>();
    final dbService = DatabaseService();
    final screenWidth = MediaQuery.of(context).size.width;

    // Categorías actualizadas con imágenes más grandes y específicas
    final List<Map<String, dynamic>> categories = [
      {
        'label': 'Animaciones',
        'image': 'https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3?q=80&w=400'
      },
      {
        'label': 'Buffet',
        'image': 'https://images.unsplash.com/photo-1555244162-803834f70033?q=80&w=400'
      },
      {
        'label': 'Coctelería',
        'image': 'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?q=80&w=400'
      },
      {
        'label': 'Decoraciones',
        'image': 'https://images.unsplash.com/photo-1519225421980-715cb0215aed?q=80&w=400'
      },
      {
        'label': 'Entretenimiento',
        'image': 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?q=80&w=400'
      },
      {
        'label': 'Mobiliario',
        'image': 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?q=80&w=400' // Sillas Tiffany y mesas
      },
    ];

    // Responsive Logic: Small screens use PageView, Large screens use Scrollable Row
    final bool isSmallScreen = screenWidth < 700;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                HomeHero(
                  onCatalogTap: () => navProvider.setSelectedIndex(1),
                ),
                // Logo centrado arriba
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Column(
                      children: [
                        const SizedBox(height: 5),
                        Image.asset(
                          'assets/images/jolus_logo.png',
                          height: 85,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.all_inclusive,
                            color: JolusColors.primaryBlue,
                            size: 36,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Botones de Menu y Notificaciones
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                          ),
                          icon: const Icon(Icons.notifications_none_rounded, color: JolusColors.primaryDarkBlue, size: 28),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // CATEGORIES SECTION
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Categorías',
                      style: GoogleFonts.manrope(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: JolusColors.primaryDarkBlue,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => navProvider.setSelectedIndex(1),
                    child: Text(
                      'Ver todas',
                      style: GoogleFonts.inter(
                        color: JolusColors.primaryBlue,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            if (isSmallScreen)
              // VIEWPORT FOR MOBILE (PageView + Dots + Arrows)
              Column(
                children: [
                  SizedBox(
                    height: (screenWidth * 0.42).clamp(150.0, 185.0), // Ajustado para evitar desbordamiento (mínimo era 135)
                    child: Stack(
                      children: [
                        PageView.builder(
                          controller: _pageController,
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final cat = categories[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: CategoryItem(
                                label: cat['label'],
                                imageUrl: cat['image'],
                                onTap: () {
                                  navProvider.setCategory(cat['label']);
                                  navProvider.setSelectedIndex(1);
                                },
                              ),
                            );
                          },
                        ),
                        // Left Arrow
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: JolusColors.primaryBlue),
                              onPressed: () {
                                if (_pageController.page == 0) {
                                  _pageController.animateToPage(
                                    categories.length - 1,
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeInOut,
                                  );
                                } else {
                                  _pageController.previousPage(
                                    duration: const Duration(milliseconds: 300), 
                                    curve: Curves.easeInOut
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                        // Right Arrow
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: IconButton(
                              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20, color: JolusColors.primaryBlue),
                              onPressed: () {
                                if (_pageController.page == categories.length - 1) {
                                  _pageController.animateToPage(
                                    0,
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeInOut,
                                  );
                                } else {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 300), 
                                    curve: Curves.easeInOut
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 0), // Eliminado espacio entre carrusel e indicador
                  GestureDetector(
                    onTapUp: (details) {
                      // El SmoothPageIndicator nativamente soporta clics si se envuelve en un widget que detecte posición o usando su controller
                    },
                    child: SmoothPageIndicator(
                      controller: _pageController,
                      count: categories.length,
                      onDotClicked: (index) => _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                      effect: const ExpandingDotsEffect(
                        dotHeight: 7,
                        dotWidth: 7,
                        activeDotColor: JolusColors.primaryBlue,
                        dotColor: JolusColors.borders,
                      ),
                    ),
                  ),
                ],
              )
            else
              // LARGE SCREEN: Fill all available space
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: categories.map((cat) {
                    return Expanded(
                      child: CategoryItem(
                        label: cat['label'],
                        imageUrl: cat['image'],
                        onTap: () {
                          navProvider.setCategory(cat['label']);
                          navProvider.setSelectedIndex(1);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

            const SizedBox(height: 32),

            // FEATURED EVENTS SECTION
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Eventos destacados',
                      style: GoogleFonts.manrope(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: JolusColors.primaryDarkBlue,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => navProvider.setSelectedIndex(1),
                    child: Text(
                      'Ver todos',
                      style: GoogleFonts.inter(
                        color: JolusColors.primaryBlue,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 380, // Adjusted to fit new Card design
              child: FutureBuilder<List<ServiceModel>>(
                future: dbService.getProducts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: JolusColors.primaryBlue));
                  }
                  
                  final products = snapshot.data ?? [];
                  final List<String> locations = [
                    "Guayaquil, Ecuador",
                    "Samborondón, Ecuador",
                    "Quito, Ecuador",
                    "Daule, Ecuador",
                    "Manta, Ecuador"
                  ];

                  return ListView.builder(
                    padding: const EdgeInsets.only(left: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: products.take(5).length,
                    itemBuilder: (context, index) {
                      return EventCard(
                        service: products[index],
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: PremiumBanner(),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
