import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/service_model.dart';
import '../../core/theme/colors.dart';
import '../screens/service_detail_screen.dart';

class EventCard extends StatelessWidget {
  final ServiceModel service;

  const EventCard({
    super.key,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ServiceDetailScreen(service: service),
        ),
      ),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 16, bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF1F7FF)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image and Badges
            Stack(
              children: [
                Hero(
                  tag: 'service_${service.id}',
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Image.network(
                      service.imagen ?? 'https://images.unsplash.com/photo-1478147427282-58a87a120781',
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 140,
                        color: JolusColors.lightBlue,
                        child: const Icon(Icons.image_not_supported, color: JolusColors.primaryBlue),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 100),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: JolusColors.primaryBlue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      service.servicio,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 12),
                        const SizedBox(width: 2),
                        Text(
                          '5.0',
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 10, color: JolusColors.primaryDarkBlue),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: JolusColors.primaryDarkBlue,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    service.descripcion,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: JolusColors.secondaryText,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFFF1F7FF)),
                  const SizedBox(height: 12),
                  Text(
                    '\$${service.precio.toInt()}',
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: JolusColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ServiceDetailScreen(service: service),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: JolusColors.primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Ver detalles', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
