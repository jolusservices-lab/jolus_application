import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import '../../core/theme/colors.dart';
import '../../core/providers/user_provider.dart';
import '../../core/services/database_service.dart';
import '../widgets/main_navigation.dart';
import 'auth/login_screen.dart';
import 'notifications_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isInfoExpanded = false;
  bool _isSocialExpanded = false;
  bool _isEditing = false;

  late TextEditingController _nameController;
  late TextEditingController _subnameController;
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
    _subnameController = TextEditingController(text: user.subname);
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
    debugPrint('DEBUG: Intentando abrir URL original: "$url"');
    if (url == '...' || url == 'No disponible' || url.isEmpty) {
      debugPrint('DEBUG: URL inválida o vacía, abortando.');
      return;
    }
    
    String finalUrl = url.trim();
    
    if (RegExp(r'^\+?[0-9\s\-]{7,20}$').hasMatch(finalUrl) || finalUrl.contains('wa.me')) {
      if (!finalUrl.startsWith('http')) {
        final cleanNumber = finalUrl.replaceAll(RegExp(r'[^0-9]'), '');
        finalUrl = 'https://wa.me/$cleanNumber';
      }
    } 
    else if (!finalUrl.startsWith('http')) {
      if (finalUrl.contains('facebook.com')) {
        finalUrl = 'https://$finalUrl';
      } else if (finalUrl.contains('instagram.com')) {
        finalUrl = 'https://$finalUrl';
      } else if (finalUrl.startsWith('@')) {
        finalUrl = 'https://instagram.com/${finalUrl.substring(1)}';
      } else {
        finalUrl = 'https://$finalUrl';
      }
    }

    debugPrint('DEBUG: URL procesada para abrir: "$finalUrl"');

    try {
      final Uri uri = Uri.parse(finalUrl);
      bool launched = await launchUrl(
        uri, 
        mode: LaunchMode.externalApplication,
      );
      
      if (!launched) {
        debugPrint('DEBUG: No se pudo abrir con aplicación externa, intentando modo plataforma...');
        launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
      }

      if (!launched) {
        throw 'No se pudo lanzar la URL';
      }
    } catch (e) {
      debugPrint('ERROR: Fallo total al abrir la URL: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
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
    _subnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image == null) return;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subiendo imagen...'), duration: Duration(seconds: 2)),
        );
      }

      final bytes = await image.readAsBytes();
      final extension = path.extension(image.path).replaceAll('.', '');
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      final publicUrl = await DatabaseService().uploadUserPhoto(
        userProvider.id,
        bytes,
        extension,
      );

      if (publicUrl != null && mounted) {
        await userProvider.updatePhotoUrl(publicUrl);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto de perfil actualizada')),
        );
      }
    } catch (e) {
      debugPrint('Error al cambiar foto: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir la imagen: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final photoUrl = userProvider.photoUrl;

    return Theme(
      data: Theme.of(context).copyWith(
        splashFactory: NoSplash.splashFactory,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        cardTheme: const CardThemeData(
          elevation: 0,
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
        listTileTheme: const ListTileThemeData(
          tileColor: Colors.transparent,
          selectedTileColor: Colors.transparent,
        ),
      ),
      child: Scaffold(
        backgroundColor: JolusColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          toolbarHeight: 70,
          titleSpacing: 0,
          automaticallyImplyLeading: false,
          title: Consumer<UserProvider>(
            builder: (context, user, _) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: JolusColors.surfaceLow,
                      backgroundImage: (user.photoUrl != null && user.photoUrl!.isNotEmpty)
                          ? NetworkImage(user.photoUrl!)
                          : null,
                      child: (user.photoUrl == null || user.photoUrl!.isEmpty)
                          ? const Icon(Icons.person, color: JolusColors.primary, size: 24)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        Text(
                            'HOLA, ${user.name} ${user.subname}'.toUpperCase().trim(),
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF00236F),
                              fontSize: 15,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Gestiona tu información personal',
                            style: GoogleFonts.inter(
                              color: Colors.grey[500],
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            IconButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
              ),
              icon: const Icon(Icons.notifications_none_rounded, color: JolusColors.primary),
            ),
            const SizedBox(width: 8),
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
                        GestureDetector(
                          onTap: _pickAndUploadImage,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                )
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 65,
                              backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                                  ? NetworkImage(photoUrl)
                                  : const NetworkImage('https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png'),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: _pickAndUploadImage,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFF00236F),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit, color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${userProvider.name} ${userProvider.subname}',
                      style: GoogleFonts.manrope(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF00236F),
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
              _AnimatedCardWrapper(
                child: Column(
                  children: [
                    ListTile(
                      onTap: () => setState(() => _isInfoExpanded = !_isInfoExpanded),
                      leading: const Icon(Icons.person_outline, color: Color(0xFF1F6FE5)),
                      title: Text(
                        'Información Personal',
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: const Color(0xFF00236F),
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
                            _buildInfoField('Apellidos', _subnameController, _isEditing),
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
                                        _isEditing = !_isEditing;
                                      });
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      side: BorderSide(color: _isEditing ? Colors.red : const Color(0xFF1F6FE5)),
                                    ),
                                    child: Text(
                                      _isEditing ? 'Cancelar' : 'Editar Información',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold,
                                        color: _isEditing ? Colors.red : const Color(0xFF1F6FE5),
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
                                          subname: _subnameController.text,
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
                                        backgroundColor: const Color(0xFF1F6FE5),
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
              const SizedBox(height: 16),
  
              // Redes Sociales Section (Acordeón)
              _AnimatedCardWrapper(
                child: Column(
                  children: [
                    ListTile(
                      onTap: () => setState(() => _isSocialExpanded = !_isSocialExpanded),
                      leading: const Icon(Icons.share_outlined, color: Color(0xFF1F6FE5)),
                      title: Text(
                        'Contactanos',
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: const Color(0xFF00236F),
                        ),
                      ),
                      trailing: Icon(
                        _isSocialExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.grey[400],
                      ),
                    ),
                    if (_isSocialExpanded)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(),
                            const SizedBox(height: 16),
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
                  ],
                ),
              ),
              const SizedBox(height: 32),
  
              // Cerrar Sesión
              TextButton.icon(
                onPressed: () async {
                  // Limpiar datos del usuario
                  userProvider.clearUser();
                  
                  // Cerrar sesión en Supabase
                  await Supabase.instance.client.auth.signOut();
                  
                  if (context.mounted) {
                    // Navegar al Login directamente
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
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
    return _AnimatedActionCard(
      icon: icon,
      title: title,
      subtitle: subtitle,
      onTap: onTap,
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
                color: iconColor.withValues(alpha: 0.1),
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

class _AnimatedCardWrapper extends StatefulWidget {
  final Widget child;
  const _AnimatedCardWrapper({required this.child});

  @override
  State<_AnimatedCardWrapper> createState() => _AnimatedCardWrapperState();
}

class _AnimatedCardWrapperState extends State<_AnimatedCardWrapper> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()
          ..translate(0.0, _isHovered ? -8.0 : 0.0)
          ..scale(_isHovered ? 1.01 : 1.0),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: widget.child,
      ),
    );
  }
}

class _AnimatedActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _AnimatedActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  State<_AnimatedActionCard> createState() => _AnimatedActionCardState();
}

class _AnimatedActionCardState extends State<_AnimatedActionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()
            ..translate(0.0, _isHovered ? -8.0 : 0.0)
            ..scale(_isHovered ? 1.01 : 1.0),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: JolusColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(widget.icon, color: JolusColors.primary),
            ),
            title: Text(
              widget.title,
              style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              widget.subtitle,
              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500]),
            ),
            trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
          ),
        ),
      ),
    );
  }
}
