import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JolusColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: JolusColors.primary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'NOTIFICACIONES',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.bold,
            color: JolusColors.primary,
            fontSize: 18,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: JolusColors.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 64,
                color: JolusColors.primary.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No tienes notificaciones aún',
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: JolusColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Te avisaremos cuando haya actualizaciones sobre tus pedidos o nuevas ofertas.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: JolusColors.onSurfaceVariant.withValues(alpha: 0.6),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
