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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);
  await SupabaseConfig.initialize();
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
}

class JolusApp extends StatefulWidget {
  const JolusApp({super.key});

  @override
  State<JolusApp> createState() => _JolusAppState();
}

class _JolusAppState extends State<JolusApp> {
  final _appLinks = AppLinks();
  StreamSubscription? _notifSubscription;

  @override
  void initState() {
    super.initState();
    _setupDeepLinks();
    _setupAuthListener();
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
    Color iconColor;

    switch (notification.type) {
      case NotificationType.order:
        icon = Icons.local_shipping_outlined;
        iconColor = Colors.blue;
        break;
      case NotificationType.product:
        icon = Icons.new_releases_outlined;
        iconColor = Colors.orange;
        break;
      case NotificationType.appUpdate:
        icon = Icons.system_update_outlined;
        iconColor = Colors.green;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  Text(
                    notification.body,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: JolusColors.darkBlue,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'ABRIR',
          textColor: Colors.amber,
          onPressed: () {
            navigatorKey.currentState?.push(
              MaterialPageRoute(builder: (context) => const NotificationsScreen()),
            );
          },
        ),
      ),
    );
  }

  void _setupDeepLinks() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        debugPrint('DEBUG DEEP LINK (Initial): $initialUri');
      }
    } catch (e) {
      debugPrint('Error obteniendo link inicial: $e');
    }

    _appLinks.uriLinkStream.listen((uri) {
      debugPrint('DEBUG DEEP LINK (Stream): $uri');
    });
  }

  void _setupAuthListener() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (event == AuthChangeEvent.passwordRecovery) {
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const UpdatePasswordScreen()),
          (route) => false,
        );
        return;
      }

      if (event == AuthChangeEvent.signedOut) {
        if (navigatorKey.currentContext != null) {
          Provider.of<NotificationProvider>(navigatorKey.currentContext!, listen: false).clearNotifications();
          Provider.of<OrderProvider>(navigatorKey.currentContext!, listen: false).clearOrders();
        }
        return;
      }

      if ((event == AuthChangeEvent.signedIn || event == AuthChangeEvent.initialSession) && session != null) {
        _syncUser(session);
        _setupNotificationListener();
      }
    });
  }

  Future<void> _syncUser(Session session) async {
    if (!mounted) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final navProvider = Provider.of<NavigationProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    
    navProvider.setSelectedIndex(0);
    final dbUser = await DatabaseService().getUser(session.user.id);
    
    if (!mounted) return;

    if (dbUser != null) {
      userProvider.setUser(
        id: dbUser.id,
        name: dbUser.name ?? '',
        email: dbUser.email,
        subname: dbUser.subname,
        photoUrl: dbUser.photoUrl,
        phone: dbUser.phone,
        address: dbUser.address,
      );
      orderProvider.fetchOrders(dbUser.id);
      notificationProvider.fetchNotifications(dbUser.id);
      notificationProvider.setupRealtimeListener(dbUser.id);
    } else {
      userProvider.syncWithSupabaseUser(session.user);
      orderProvider.fetchOrders(session.user.id);
      notificationProvider.fetchNotifications(session.user.id);
      notificationProvider.setupRealtimeListener(session.user.id);
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
