import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/colors.dart';
import '../../core/providers/user_provider.dart';
import '../../core/services/database_service.dart';
import '../widgets/main_navigation.dart';
import 'auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isInfoExpanded = false;
  bool _isEditing = false;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  String _whatsapp = '...';
  String _instagram = '...';
  String _facebook = '...';
  String _usernameHandle = '...';

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false);
    _nameController = TextEditingController(text: user.name);
    _emailController = TextEditingController(text: user.email);
    _phoneController = TextEditingController(text: user.phone);
    _addressController = TextEditingController(text: user.address);
    _fetchSocialLinks();
  }

  Future<void> _fetchSocialLinks() async {
    try {
      final adminProfile = await DatabaseService().getAdminProfile();

      if (mounted) {
        if (adminProfile != null) {
          setState(() {
            _facebook = adminProfile.linkFacebook ?? '';
            _instagram = adminProfile.linkInstagram ?? '';
            _whatsapp = adminProfile.linkWhatsapp ?? '';
            _usernameHandle = adminProfile.nombreUsuarioArroba ?? 'jolus_app';
          });
        } else {
          setState(() {
            _facebook = '';
            _instagram = '';
            _whatsapp = '';
            _usernameHandle = '';
          });
        }
      }
    } catch (e) {
      debugPrint('Error cargando redes sociales: $e');
    }
  }

  Future<void> _launchURL(String url) async {
    print('DEBUG: Intentando abrir URL original: "$url"');
    if (url == '...' || url == 'No disponible' || url.isEmpty) {
      print('DEBUG: URL inválida o vacía, abortando.');
      return;
    }
    
    String finalUrl = url.trim();
    
    // Lógica para WhatsApp
    if (RegExp(r'^\+?[0-9\s\-]{7,20}$').hasMatch(finalUrl) || finalUrl.contains('wa.me')) {
      if (!finalUrl.startsWith('http')) {
        final cleanNumber = finalUrl.replaceAll(RegExp(r'[^0-9]'), '');
        finalUrl = 'https://wa.me/$cleanNumber';
      }
    } 
    // Lógica para Redes Sociales si no tienen protocolo
    else if (!finalUrl.startsWith('http')) {
      if (finalUrl.contains('facebook.com')) {
        finalUrl = 'https://$finalUrl';
      } else if (finalUrl.contains('instagram.com')) {
        finalUrl = 'https://$finalUrl';
      } else if (finalUrl.startsWith('@')) {
        finalUrl = 'https://instagram.com/${finalUrl.substring(1)}';
      } else {
        // Intento genérico si parece un dominio
        finalUrl = 'https://$finalUrl';
      }
    }

    print('DEBUG: URL procesada para abrir: "$finalUrl"');

    try {
      final Uri uri = Uri.parse(finalUrl);
      // Intentamos primero con la aplicación externa
      bool launched = await launchUrl(
        uri, 
        mode: LaunchMode.externalApplication,
      );
      
      if (!launched) {
        print('DEBUG: No se pudo abrir con aplicación externa, intentando modo plataforma...');
        launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
      }

      if (!launched) {
        throw 'No se pudo lanzar la URL';
      }
    } catch (e) {
      print('ERROR: Fallo total al abrir la URL: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo abrir el enlace. Verifica si tienes la app instalada o la URL es válida.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JolusColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: JolusColors.primary),
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
        title: Text(
          'Mi Perfil',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.bold,
            color: JolusColors.primary,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined, color: JolusColors.primary),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage('https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?q=80&w=200'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            // Perfil Header
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            )
                          ],
                        ),
                        child: const CircleAvatar(
                          radius: 65,
                          backgroundImage: NetworkImage('https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?q=80&w=400'),
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF00236F),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _nameController.text,
                    style: GoogleFonts.manrope(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: JolusColors.primary,
                    ),
                  ),
                  Text(
                    _emailController.text,
                    style: GoogleFonts.inter(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Información Personal (Acordeón)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ListTile(
                    onTap: () => setState(() => _isInfoExpanded = !_isInfoExpanded),
                    leading: const Icon(Icons.person_outline, color: JolusColors.primary),
                    title: Text(
                      'Información Personal',
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: JolusColors.primary,
                      ),
                    ),
                    trailing: Icon(
                      _isInfoExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.grey[400],
                    ),
                  ),
                  if (_isInfoExpanded)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Column(
                        children: [
                          const Divider(),
                          const SizedBox(height: 16),
                          _buildInfoField('Nombres', _nameController, _isEditing),
                          const SizedBox(height: 16),
                          _buildInfoField('Correo', _emailController, _isEditing),
                          const SizedBox(height: 16),
                          _buildInfoField('Teléfono', _phoneController, _isEditing),
                          const SizedBox(height: 16),
                          _buildInfoField('Dirección', _addressController, _isEditing),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      if (_isEditing) {
                                        // Cancelar edición (podría restaurar valores originales)
                                        _isEditing = false;
                                      } else {
                                        _isEditing = true;
                                      }
                                    });
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    side: BorderSide(color: _isEditing ? Colors.red : JolusColors.primary),
                                  ),
                                  child: Text(
                                    _isEditing ? 'Cancelar' : 'Editar Información',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                      color: _isEditing ? Colors.red : JolusColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                              if (_isEditing) ...[
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      await Provider.of<UserProvider>(context, listen: false).updateProfile(
                                        name: _nameController.text,
                                        email: _emailController.text,
                                        phone: _phoneController.text,
                                        address: _addressController.text,
                                      );
                                      if (context.mounted) {
                                        setState(() {
                                          _isEditing = false;
                                        });
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Cambios guardados exitosamente')),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: JolusColors.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      elevation: 0,
                                    ),
                                    child: const Text('Guardar Cambios', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Otros items
            _buildActionCard(
              icon: Icons.credit_card_outlined,
              title: 'Métodos de Pago',
              subtitle: 'Visa **** 1234',
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              icon: Icons.shopping_bag_outlined,
              title: 'Mis Pedidos',
              subtitle: 'Historial de compras',
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const MainNavigation(initialIndex: 3)),
                  (route) => false,
                );
              },
            ),
            const SizedBox(height: 24),

            // Redes Sociales Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.share_outlined, color: JolusColors.primary),
                      const SizedBox(width: 12),
                      Text(
                        'Redes Sociales',
                        style: GoogleFonts.manrope(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: JolusColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSocialTile(
                    icon: Icons.chat_bubble_outline,
                    iconColor: Colors.green,
                    title: 'WhatsApp',
                    value: _usernameHandle,
                    onTap: () => _launchURL(_whatsapp),
                  ),
                  const SizedBox(height: 12),
                  _buildSocialTile(
                    icon: Icons.camera_alt_outlined,
                    iconColor: Colors.pink,
                    title: 'Instagram',
                    value: _usernameHandle,
                    onTap: () => _launchURL(_instagram),
                  ),
                  const SizedBox(height: 12),
                  _buildSocialTile(
                    icon: Icons.facebook_outlined,
                    iconColor: Colors.blue,
                    title: 'Facebook',
                    value: _usernameHandle,
                    onTap: () => _launchURL(_facebook),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(),
                  ),
                  Text(
                    'Estado de Cuenta',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Verificado',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Cerrar Sesión
            TextButton.icon(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              ),
              icon: const Icon(Icons.logout, color: Colors.red),
              label: Text(
                'Cerrar Sesión',
                style: GoogleFonts.inter(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoField(String label, TextEditingController controller, bool isEditing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.grey[500],
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: isEditing,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: isEditing ? Colors.black87 : Colors.grey[700],
          ),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            border: isEditing ? const UnderlineInputBorder() : InputBorder.none,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({required IconData icon, required String title, required String subtitle, VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: JolusColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: JolusColors.primary),
        ),
        title: Text(
          title,
          style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500]),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
      ),
    );
  }

  Widget _buildSocialTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    value,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (onTap != null && value != '...' && value != 'No disponible')
              Icon(Icons.open_in_new, size: 16, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }
}
