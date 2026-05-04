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
import 'forgot_password_screen.dart';

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
      
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = res.user;
      if (user != null) {
        final userData = await DatabaseService().getUser(user.id);
        
        if (mounted) {
          final userProvider = context.read<UserProvider>();
          
          if (userData != null) {
            await userProvider.setUser(
              id: user.id,
              name: userData.name ?? '',
              subname: userData.subname ?? '',
              email: userData.email ?? '',
              phone: userData.phone ?? '',
              address: userData.address ?? '',
              photoUrl: userData.photoUrl,
            );
          } else {
            await userProvider.syncWithSupabaseUser(user);
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
      String message = e.message;
      if (message == 'Invalid login credentials') {
        message = 'Usuario o contraseña incorrectos';
      }
      _showError(message);
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
      backgroundColor: const Color(0xFFF8FAFF),
      body: Stack(
        children: [
          // Background Decorations (Dots/Circles based on image)
          Positioned(
            top: 40,
            left: 20,
            child: _DotsGrid(),
          ),
          Positioned(
            bottom: 40,
            right: 20,
            child: _DotsGrid(),
          ),
          // Waves/Curved backgrounds
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.3,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xFFE7F1FF)],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Logo and Brand Name
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/jolus_logo.png',
                            height: 60,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.business, size: 40, color: Color(0xFF0038A8)),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Jolus Services',
                            style: GoogleFonts.manrope(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF00236F),
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Bienvenido de nuevo. Inicia sesión en tu cuenta.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      // Central White Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
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
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF00236F),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _emailController,
                              validator: (value) => (value == null || value.isEmpty) ? 'Ingresa tu correo' : null,
                              decoration: InputDecoration(
                                hintText: 'ejemplo@correo.com',
                                prefixIcon: Container(
                                  padding: const EdgeInsets.all(12),
                                  child: const Icon(Icons.mail_outline_rounded, color: Color(0xFF1F6FE5), size: 22),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[200]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[200]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFF1F6FE5)),
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
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF00236F),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero, 
                                    minimumSize: Size.zero, 
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap
                                  ),
                                  child: Text(
                                    '¿Olvidaste tu contraseña?',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1F6FE5),
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
                                prefixIcon: Container(
                                  padding: const EdgeInsets.all(12),
                                  child: const Icon(Icons.lock_outline_rounded, color: Color(0xFF1F6FE5), size: 22),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                    size: 20,
                                    color: Colors.grey[600],
                                  ),
                                  onPressed: () => setState(() => _obscureText = !_obscureText),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[200]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[200]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFF1F6FE5)),
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                            const SizedBox(height: 32),
                            // Gradient Login Button
                            Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF0038A8), Color(0xFF5A9CF8)],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                              ),
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: _isLoading 
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Spacer(),
                                        Text(
                                          'Iniciar sesión',
                                          style: GoogleFonts.manrope(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const Spacer(),
                                        const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                                      ],
                                    ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(child: Divider(color: Colors.grey[200])),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'o continuar con',
                                    style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500]),
                                  ),
                                ),
                                Expanded(child: Divider(color: Colors.grey[200])),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _SocialButton(
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
                                        await userProvider.setUser(
                                          id: userData.id,
                                          name: userData.name ?? '',
                                          subname: userData.subname ?? '',
                                          email: userData.email ?? '',
                                          phone: userData.phone ?? '',
                                          address: userData.address ?? '',
                                          photoUrl: userData.photoUrl,
                                        );
                                      } else {
                                        await userProvider.syncWithSupabaseUser(response.user);
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
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '¿No tienes una cuenta? ',
                            style: GoogleFonts.inter(color: Colors.grey[700]),
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
                                color: const Color(0xFF1F6FE5),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DotsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(4, (i) => Row(
        children: List.generate(4, (j) => Container(
          width: 4,
          height: 4,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[300],
          ),
        )),
      )),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData? icon;
  final String label;
  final VoidCallback onPressed;

  const _SocialButton({this.icon, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: BorderSide(color: Colors.grey[200]!),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null)
            Icon(
              icon, 
              size: 24, 
              color: label == 'Google' ? Colors.red : Colors.black
            ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
