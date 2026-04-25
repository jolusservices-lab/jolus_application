import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/colors.dart';
import '../widgets/filter_chip.dart';
import '../widgets/service_detail_card.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  String _selectedCategory = 'Todos';

  final List<Map<String, dynamic>> _allServices = [
    {
      'id': 'd1',
      'category': 'DECORACIONES',
      'title': 'Diseño de Interiores',
      'description': 'Arcos de globos orgánicos, centros de mesa florales y temáticas...',
      'price': 150.0,
      'priceLabel': 'Desde',
      'imageUrl': 'https://images.unsplash.com/photo-1519225421980-715cb0215aed?q=80&w=800',
      'tags': [
        {'icon': Icons.edit_outlined, 'label': 'Premium'},
        {'icon': Icons.palette_outlined, 'label': 'Custom'},
      ],
    },
    {
      'id': 'b1',
      'category': 'BUFFET',
      'title': 'Catering Gourmet',
      'description': 'Variedad de platillos internacionales y estaciones de comida en vivo para sus...',
      'price': 35.0,
      'priceLabel': 'P/Persona',
      'imageUrl': 'https://images.unsplash.com/photo-1555244162-803834f70033?q=80&w=800',
      'tags': [
        {'icon': Icons.restaurant_menu, 'label': 'Menú Chef'},
        {'icon': Icons.person_outline, 'label': 'Meseros'},
      ],
    },
    {
      'id': 'c1',
      'category': 'COCTELERÍA',
      'title': 'Barra Móvil Express',
      'description': 'Mixología creativa, cócteles clásicos y mocktails preparados por bartenders...',
      'price': 280.0,
      'priceLabel': 'Desde',
      'imageUrl': 'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?q=80&w=800',
      'tags': [
        {'icon': Icons.local_bar, 'label': 'Open Bar'},
        {'icon': Icons.access_time, 'label': '4 Horas'},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredServices = _selectedCategory == 'Todos'
        ? _allServices
        : _allServices.where((s) => s['category'].toLowerCase() == _selectedCategory.toLowerCase()).toList();

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
                Text(
                  'Servicios para Eventos',
                  style: GoogleFonts.manrope(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF00236F),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Diseñamos experiencias inolvidables para tus celebraciones.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  decoration: InputDecoration(
                    hintText: '¿Qué necesitas para tu evento?',
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
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      'Todos',
                      'Decoraciones',
                      'Buffet',
                      'Coctelería',
                      'Mobiliario'
                    ].map((category) {
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = category),
                        child: FilterChipWidget(
                          label: category,
                          isSelected: _selectedCategory == category,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 32),
                ...filteredServices.map((service) => Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: ServiceDetailCard(
                        id: service['id'],
                        category: service['category'],
                        title: service['title'],
                        description: service['description'],
                        price: service['price'],
                        priceLabel: service['priceLabel'],
                        imageUrl: service['imageUrl'],
                        tags: List<Map<String, dynamic>>.from(service['tags']),
                      ),
                    )),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
