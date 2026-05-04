import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/services/database_service.dart';
import '../../../core/models/user_model.dart';
import '../../../core/providers/user_provider.dart';
import 'welcome_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  bool _isLoading = false;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      final dbService = DatabaseService();
      final email = _emailController.text.trim();

      // 1. Validar si el correo ya existe en la tabla 'usuarios'
      final bool exists = await dbService.checkEmailExists(email);
      if (exists) {
        _showError('Este correo electrónico ya está registrado. Por favor, utiliza otro.');
        return;
      }
      
      // 2. Crear usuario en Supabase Auth
      final AuthResponse res = await supabase.auth.signUp(
        email: email,
        password: _passwordController.text.trim(),
        data: {
          'full_name': '${_firstNameController.text} ${_lastNameController.text}',
        },
      );

      final user = res.user;
      if (user != null) {
        // 2. Crear modelo de usuario con todos los campos para la tabla 'usuarios'
        final newUser = UserModel(
          id: user.id,
          email: _emailController.text.trim(),
          name: _firstNameController.text.trim(),
          subname: _lastNameController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          photoUrl: null,
        );

        // 3. Guardar en la tabla 'usuarios' de Supabase
        await DatabaseService().syncUser(newUser);

        // 4. Mostrar por pantalla los datos enviados y confirmar la carga
        if (mounted) {
          // Actualizar estado local
          await context.read<UserProvider>().setUser(
            id: newUser.id,
            name: newUser.name ?? '',
            subname: newUser.subname ?? '',
            email: newUser.email ?? '',
            phone: newUser.phone,
            address: newUser.address,
          );

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 10),
                  Text('¡Datos Cargados!'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('La siguiente información se ha sincronizado con la tabla "usuarios":', 
                    style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  Text('• Correo: ${newUser.email}'),
                  Text('• Nombres: ${newUser.name}'),
                  Text('• Apellidos: ${newUser.subname}'),
                  Text('• Teléfono: ${newUser.phone}'),
                  Text('• Dirección: ${newUser.address}'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Cerrar diálogo
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WelcomeScreen(
                          username: _firstNameController.text,
                          isNewAccount: true,
                        ),
                      ),
                      (route) => false,
                    );
                  },
                  child: const Text('Confirmar y Continuar', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        }
      }
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Ocurrió un error inesperado: $e');
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
          // Background Decorations
          Positioned(
            top: 100,
            left: -20,
            child: _DotsGrid(),
          ),
          Positioned(
            top: 200,
            right: -20,
            child: _DotsGrid(),
          ),
          // Wave/Gradient Background
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.4,
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
            child: Column(
              children: [
                // Top Navigation Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Color(0xFF00236F)),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Image.asset(
                        'assets/images/jolus_logo.png',
                        height: 32,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.business, size: 24, color: Color(0xFF0038A8)),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Jolus Services',
                        style: GoogleFonts.manrope(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF00236F),
                        ),
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Central White Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 24,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Crear Cuenta',
                                  style: GoogleFonts.manrope(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF00236F),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Completa los siguientes datos para crear tu cuenta.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 32),
                                
                                _buildInputField(
                                  controller: _firstNameController,
                                  label: 'Nombres',
                                  hint: 'Ej. Juan',
                                  icon: Icons.person_outline_rounded,
                                ),
                                const SizedBox(height: 20),
                                _buildInputField(
                                  controller: _lastNameController,
                                  label: 'Apellidos',
                                  hint: 'Ej. Pérez',
                                  icon: Icons.badge_outlined,
                                ),
                                const SizedBox(height: 20),
                                _buildInputField(
                                  controller: _phoneController,
                                  label: 'Teléfono',
                                  hint: 'Ej. 1234 5678',
                                  icon: Icons.phone_outlined,
                                  keyboardType: TextInputType.phone,
                                ),
                                const SizedBox(height: 20),
                                _buildInputField(
                                  controller: _addressController,
                                  label: 'Dirección',
                                  hint: 'Ciudad, Zona, Calle, etc.',
                                  icon: Icons.location_on_outlined,
                                ),
                                const SizedBox(height: 20),
                                _buildInputField(
                                  controller: _emailController,
                                  label: 'Correo Electrónico',
                                  hint: 'usuario@ejemplo.com',
                                  icon: Icons.mail_outline_rounded,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 20),
                                _buildPasswordFieldNew(),
                                
                                const SizedBox(height: 40),
                                
                                // Register Button
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
                                    onPressed: _isLoading ? null : _handleRegister,
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
                                            Text(
                                              'Registrar Cuenta',
                                              style: GoogleFonts.manrope(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                                          ],
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Footer
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '¿Ya tienes una cuenta? ',
                                style: GoogleFonts.inter(color: Colors.grey[700]),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  'Inicia sesión',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF1F6FE5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF00236F),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFE7F1FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF1F6FE5), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                validator: (value) => (value == null || value.isEmpty) ? 'Campo requerido' : null,
                style: GoogleFonts.inter(fontSize: 14),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: GoogleFonts.inter(color: Colors.grey[400], fontSize: 14),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPasswordFieldNew() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contraseña',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF00236F),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFE7F1FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.lock_outline_rounded, color: Color(0xFF1F6FE5), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _passwordController,
                obscureText: _obscureText,
                style: GoogleFonts.inter(fontSize: 14),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo requerido';
                  if (value.length < 8) return 'Mínimo 8 caracteres';
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Mínimo 8 caracteres',
                  hintStyle: GoogleFonts.inter(color: Colors.grey[400], fontSize: 14),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 20,
                      color: Colors.grey[600],
                    ),
                    onPressed: () => setState(() => _obscureText = !_obscureText),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DotsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(5, (i) => Row(
        children: List.generate(5, (j) => Container(
          width: 4,
          height: 4,
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[300]!.withOpacity(0.5),
          ),
        )),
      )),
    );
  }
}
