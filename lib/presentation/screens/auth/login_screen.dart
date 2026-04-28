import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/auth_service.dart';
import '../../../core/services/database_service.dart';
import '../../../core/providers/user_provider.dart';
import 'register_screen.dart';
import 'welcome_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      
      // 1. Iniciar sesión en Supabase Auth
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = res.user;
      if (user != null) {
        // 2. Obtener información extendida de la tabla 'usuarios'
        final userData = await DatabaseService().getUser(user.id);
        
        if (mounted) {
          final userProvider = context.read<UserProvider>();
          
          if (userData != null) {
            // Sincronizar provider con los datos de la tabla 'usuarios'
            await userProvider.updateProfile(
              name: userData.name ?? '',
              email: userData.email ?? '',
              phone: userData.phone ?? '',
              address: userData.address ?? '',
            );
            // Asegurar que el ID y photo esten seteados
            userProvider.setUser(
              id: user.id,
              name: userData.name ?? '',
              email: userData.email ?? '',
              photoUrl: userData.photoUrl,
            );
          } else {
            // Si no existe en la tabla usuarios (por algún error previo), sincronizar lo básico del Auth
            userProvider.syncWithSupabaseUser(user);
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => WelcomeScreen(
                username: userProvider.name.split(' ')[0],
                isNewAccount: false,
              ),
            ),
          );
        }
      }
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Error inesperado: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JolusColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 60),
                Text(
                  'Jolus Services',
                  style: GoogleFonts.manrope(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: JolusColors.primary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bienvenido de nuevo. Inicia sesión en tu cuenta.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: JolusColors.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 48),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Correo electrónico',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: JolusColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        validator: (value) => (value == null || value.isEmpty) ? 'Ingresa tu correo' : null,
                        decoration: InputDecoration(
                          hintText: 'ejemplo@correo.com',
                          prefixIcon: const Icon(Icons.mail_outline_rounded, size: 20),
                          filled: true,
                          fillColor: JolusColors.surfaceLow.withValues(alpha: 0.5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Contraseña',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: JolusColors.primary,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(padding: EdgeInsets.zero),
                            child: Text(
                              '¿Olvidaste tu contraseña?',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: JolusColors.primaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscureText,
                        validator: (value) => (value == null || value.isEmpty) ? 'Ingresa tu contraseña' : null,
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              size: 20,
                            ),
                            onPressed: () => setState(() => _obscureText = !_obscureText),
                          ),
                          filled: true,
                          fillColor: JolusColors.surfaceLow.withValues(alpha: 0.5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: JolusColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isLoading 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                'Iniciar sesión',
                                style: GoogleFonts.manrope(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(child: Divider(color: JolusColors.outlineVariant.withValues(alpha: 0.5))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'o continuar con',
                              style: GoogleFonts.inter(fontSize: 12, color: JolusColors.onSurfaceVariant.withValues(alpha: 0.5)),
                            ),
                          ),
                          Expanded(child: Divider(color: JolusColors.outlineVariant.withValues(alpha: 0.5))),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _SocialButton(
                              icon: Icons.g_mobiledata,
                              label: 'Google',
                              onPressed: () async {
                                try {
                                  final authService = AuthService();
                                  final response = await authService.signInWithGoogle();
                                  if (response?.user != null) {
                                    if (mounted) {
                                      final userProvider = context.read<UserProvider>();
                                      final userData = await DatabaseService().getUser(response!.user!.id);
                                      
                                      if (userData != null) {
                                        userProvider.setUser(
                                          id: userData.id,
                                          name: userData.name ?? '',
                                          email: userData.email ?? '',
                                          photoUrl: userData.photoUrl,
                                        );
                                      } else {
                                        userProvider.syncWithSupabaseUser(response.user);
                                      }

                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => WelcomeScreen(
                                            username: userProvider.name.split(' ')[0],
                                            isNewAccount: false,
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error al iniciar sesión con Google: $e')),
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(child: _SocialButton(icon: Icons.apple, label: 'Apple', onPressed: () {})),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿No tienes una cuenta? ',
                      style: GoogleFonts.inter(color: JolusColors.onSurfaceVariant),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                      ),
                      child: Text(
                        'Crear cuenta',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w800,
                          color: JolusColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Text(
                  '© 2024 Jolus Services. Todos los derechos reservados.',
                  style: GoogleFonts.inter(fontSize: 11, color: JolusColors.onSurfaceVariant.withValues(alpha: 0.5)),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _SocialButton({required this.icon, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 24, color: JolusColors.onSurfaceVariant),
      label: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: JolusColors.onSurfaceVariant,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: BorderSide(color: JolusColors.outlineVariant.withValues(alpha: 0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
