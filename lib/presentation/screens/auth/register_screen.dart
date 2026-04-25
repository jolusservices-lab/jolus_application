import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/colors.dart';
import 'welcome_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JolusColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: JolusColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Jolus Services',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.bold,
            color: JolusColors.primary,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: JolusColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: JolusColors.outlineVariant.withValues(alpha: 0.5)),
                boxShadow: [
                  BoxShadow(
                    color: JolusColors.primary.withValues(alpha: 0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Crear Cuenta',
                    style: GoogleFonts.manrope(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: JolusColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Regístrate para gestionar tus servicios',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: JolusColors.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _RegisterField(label: 'Nombres', hint: 'Ej. Juan', icon: Icons.person_outline),
                  const SizedBox(height: 16),
                  _RegisterField(label: 'Apellidos', hint: 'Ej. Pérez', icon: Icons.badge_outlined),
                  const SizedBox(height: 16),
                  _RegisterField(label: 'Teléfono', hint: '+502 0000-0000', icon: Icons.phone_outlined),
                  const SizedBox(height: 16),
                  _RegisterField(label: 'Dirección', hint: 'Calle, Avenida, Zona...', icon: Icons.location_on_outlined),
                  const SizedBox(height: 16),
                  _RegisterField(label: 'Correo Electrónico', hint: 'usuario@ejemplo.com', icon: Icons.mail_outline),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.lock_outline, size: 18, color: JolusColors.onSurfaceVariant),
                          const SizedBox(width: 8),
                          Text(
                            'Contraseña',
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          hintText: 'Mínimo 8 caracteres',
                          suffixIcon: IconButton(
                            icon: Icon(_obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                            onPressed: () => setState(() => _obscureText = !_obscureText),
                          ),
                          filled: true,
                          fillColor: JolusColors.surfaceLow.withValues(alpha: 0.5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WelcomeScreen(
                            username: 'Nuevo Usuario',
                            isNewAccount: true,
                          ),
                        ),
                        (route) => false,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: JolusColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Registrar Cuenta',
                            style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('¿Ya tienes una cuenta? ', style: GoogleFonts.inter()),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Inicia sesión',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: JolusColors.primary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Text(
              '© 2024 Jolus Services. Todos los derechos reservados.',
              style: GoogleFonts.inter(fontSize: 11, color: JolusColors.onSurfaceVariant.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _FooterLink(label: 'Términos y Condiciones'),
                _FooterLink(label: 'Privacidad'),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _RegisterField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;

  const _RegisterField({required this.label, required this.hint, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: JolusColors.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: JolusColors.surfaceLow.withValues(alpha: 0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String label;
  const _FooterLink({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: JolusColors.primary,
        ),
      ),
    );
  }
}
