import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/models/service_model.dart';
import '../screens/service_detail_screen.dart';

class ServiceCard extends StatelessWidget {
  final ServiceModel service;

  const ServiceCard({
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
              color: Colors.black.withOpacity(0.05),
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
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    image: DecorationImage(
                      image: NetworkImage(service.imagen ?? 'https://via.placeholder.com/400'),
                      fit: BoxFit.cover,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          service.nombre,
                          style: GoogleFonts.manrope(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: JolusColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Text(
                        '\$${service.precio.toStringAsFixed(0)}',
                        style: GoogleFonts.manrope(
                          color: JolusColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    service.descripcion,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: Colors.grey[600],
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<CartProvider>().addItem(
                          service.id,
                          service.nombre,
                          service.precio,
                          service.imagen ?? '',
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${service.nombre} añadido')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: JolusColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Añadir al carrito'),
                    ),
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
