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
    return _AnimatedServiceDetailCard(service: service);
  }
}

class _AnimatedServiceDetailCard extends StatefulWidget {
  final ServiceModel service;
  const _AnimatedServiceDetailCard({required this.service});

  @override
  State<_AnimatedServiceDetailCard> createState() => _AnimatedServiceDetailCardState();
}

class _AnimatedServiceDetailCardState extends State<_AnimatedServiceDetailCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceDetailScreen(service: widget.service),
          ),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()
            ..translate(0.0, _isHovered ? -8.0 : 0.0)
            ..scale(_isHovered ? 1.01 : 1.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isHovered ? 0.12 : 0.05),
                blurRadius: _isHovered ? 25 : 15,
                offset: Offset(0, _isHovered ? 12 : 8),
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
                    child: Hero(
                      tag: 'service_detail_image_${widget.service.id}',
                      child: Image.network(
                        widget.service.imagen ?? 'https://via.placeholder.com/400',
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          if (_isHovered)
                            BoxShadow(
                              color: JolusColors.primary.withOpacity(0.2),
                              blurRadius: 8,
                            )
                        ],
                      ),
                      child: Text(
                        widget.service.categoria.toUpperCase(),
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
                      widget.service.nombre,
                      style: GoogleFonts.manrope(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: JolusColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.service.descripcion,
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
                          'Disponible: ${widget.service.cantidad}',
                          style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${widget.service.precio.toStringAsFixed(2)}',
                          style: GoogleFonts.manrope(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: JolusColors.primary,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            context.read<CartProvider>().addItem(
                              widget.service.id,
                              widget.service.nombre,
                              widget.service.precio,
                              widget.service.imagen ?? '',
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${widget.service.nombre} añadido al carrito'),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: JolusColors.primary,
                            foregroundColor: Colors.white,
                            elevation: _isHovered ? 4 : 0,
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
      ),
    );
  }
}
