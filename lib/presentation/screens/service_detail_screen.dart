import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/models/service_model.dart';
import '../../core/providers/cart_provider.dart';

class ServiceDetailScreen extends StatelessWidget {
  final ServiceModel service;

  const ServiceDetailScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: JolusColors.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    service.imagen ?? 'https://via.placeholder.com/800',
                    fit: BoxFit.cover,
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black26, Colors.transparent, Colors.black54],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: JolusColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          service.categoria.toUpperCase(),
                          style: GoogleFonts.inter(
                            color: JolusColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Text(
                        '\$${service.precio}',
                        style: GoogleFonts.manrope(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: JolusColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    service.nombre,
                    style: GoogleFonts.manrope(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: JolusColors.onBackground,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Servicio de ${service.servicio}',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: JolusColors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),
                  Text(
                    'Descripción',
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    service.descripcion,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: JolusColors.onSurfaceVariant,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildInfoRow(Icons.inventory_2_outlined, 'Disponibilidad', '${service.cantidad} unidades'),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {
              context.read<CartProvider>().addItem(
                service.id,
                service.nombre,
                service.precio,
                service.imagen ?? '',
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Añadido al carrito')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: JolusColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: Text(
              'Añadir al Carrito',
              style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: JolusColors.primary),
        const SizedBox(width: 12),
        Text(
          '$title:',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: JolusColors.onSurfaceVariant),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: GoogleFonts.inter(color: JolusColors.onBackground),
        ),
      ],
    );
  }
}
