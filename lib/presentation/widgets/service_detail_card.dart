import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/models/service_model.dart';
import '../../core/theme/colors.dart';
import '../screens/service_detail_screen.dart';

class ServiceDetailCard extends StatelessWidget {
  final ServiceModel service;

  const ServiceDetailCard({
    super.key,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ServiceDetailScreen(service: service),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Image.network(
                    service.imagen ?? 'https://via.placeholder.com/400',
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      service.categoria.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        color: JolusColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.nombre,
                    style: GoogleFonts.manrope(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: JolusColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    service.descripcion,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: Colors.grey[600],
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.inventory_2_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        'Disponible: ${service.cantidad}',
                        style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${service.precio.toStringAsFixed(2)}',
                        style: GoogleFonts.manrope(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: JolusColors.primary,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          context.read<CartProvider>().addItem(
                            service.id,
                            service.nombre,
                            service.precio,
                            service.imagen ?? '',
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${service.nombre} añadido al carrito')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: JolusColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: const Text('Reservar', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
