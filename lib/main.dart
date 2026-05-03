import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_links/app_links.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/colors.dart';
import 'core/providers/cart_provider.dart';
import 'core/providers/user_provider.dart';
import 'core/providers/order_provider.dart';
import 'core/providers/navigation_provider.dart';
import 'core/providers/notification_provider.dart';
import 'presentation/screens/auth/splash_screen.dart';
import 'presentation/screens/auth/update_password_screen.dart';
import 'presentation/screens/notifications_screen.dart';
import 'core/supabase_config.dart';
import 'core/services/database_service.dart';
import 'core/models/notification_model.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  // 1. Iniciamos los bindings de Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Ejecutamos la app de inmediato para evitar que el OS bloquee la pantalla
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProxyProvider<UserProvider, CartProvider>(
          create: (context) => CartProvider(),
          update: (context, userProvider, cartProvider) =>
              cartProvider!..updateUserId(userProvider.id),
        ),
        ChangeNotifierProvider(create: (context) => OrderProvider()),
        ChangeNotifierProvider(create: (context) => NavigationProvider()),
        ChangeNotifierProvider(create: (context) => NotificationProvider()),
      ],
      child: const JolusApp(),
    ),
  );

  // 3. Inicializamos los servicios pesados en segundo plano
  _initServices();
}

Future<void> _initServices() async {
  try {
    await initializeDateFormatting('es', null).timeout(const Duration(seconds: 2));
    await SupabaseConfig.initialize().timeout(const Duration(seconds: 10));
    debugPrint('Servicios inicializados con éxito');
  } catch (e) {
    debugPrint('Error en inicialización (no crítico): $e');
  }
}

class JolusApp extends StatefulWidget {
  const JolusApp({super.key});

  @override
  State<JolusApp> createState() => _JolusAppState();
}

class _JolusAppState extends State<JolusApp> {
  final _appLinks = AppLinks();
  StreamSubscription? _notifSubscription;
  bool _isAuthListenerSet = false;

  @override
  void initState() {
    super.initState();
    _setupDeepLinks();
    _trySetupAuthListener();
  }

  // Intentamos configurar el listener de Auth periódicamente hasta que Supabase esté listo
  void _trySetupAuthListener() {
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      try {
        if (Supabase.instance.client != null) {
          _setupAuthListener();
          _isAuthListenerSet = true;
          timer.cancel();
        }
      } catch (_) {
        // Supabase aún no inicializado
      }
    });
  }

  @override
  void dispose() {
    _notifSubscription?.cancel();
    super.dispose();
  }

  void _setupNotificationListener() {
    if (_notifSubscription != null) return;
    
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    _notifSubscription = notificationProvider.onNewNotification.listen((notification) {
      _showNotificationSnackBar(notification);
    });
  }

  void _showNotificationSnackBar(NotificationModel notification) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    IconData icon;
    switch (notification.type) {
      case NotificationType.order: icon = Icons.local_shipping_outlined; break;
      case NotificationType.product: icon = Icons.new_releases_outlined; break;
      case NotificationType.appUpdate: icon = Icons.system_update_outlined; break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.notifications_active, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notification.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(notification.body, maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: JolusColors.darkBlue,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'VER',
          textColor: Colors.amber,
          onPressed: () => navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (context) => const NotificationsScreen()),
          ),
        ),
      ),
    );
  }

  void _setupDeepLinks() async {
    _appLinks.uriLinkStream.listen((uri) => debugPrint('Deep Link: $uri'));
  }

  void _setupAuthListener() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;

      if (event == AuthChangeEvent.passwordRecovery) {
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const UpdatePasswordScreen()),
          (route) => false,
        );
      } else if (event == AuthChangeEvent.signedOut) {
        // Limpiar estados
      } else if ((event == AuthChangeEvent.signedIn || event == AuthChangeEvent.initialSession) && session != null) {
        _syncUser(session);
        _setupNotificationListener();
      }
    });
  }

  Future<void> _syncUser(Session session) async {
    if (!mounted) return;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final dbUser = await DatabaseService().getUser(session.user.id);
    
    if (dbUser != null) {
      userProvider.setUser(
        id: dbUser.id,
        name: dbUser.name ?? '',
        email: dbUser.email,
        phone: dbUser.phone,
        address: dbUser.address,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Jolus Services',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
