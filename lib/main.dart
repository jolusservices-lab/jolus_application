import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_links/app_links.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/cart_provider.dart';
import 'core/providers/user_provider.dart';
import 'core/providers/order_provider.dart';
import 'core/providers/navigation_provider.dart';
import 'presentation/screens/auth/splash_screen.dart';
import 'presentation/screens/auth/update_password_screen.dart';
import 'core/supabase_config.dart';
import 'core/services/database_service.dart';

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

  @override
  void initState() {
    super.initState();
    _setupDeepLinks();
    _setupAuthListener();
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

      if ((event == AuthChangeEvent.signedIn || event == AuthChangeEvent.initialSession) && session != null) {
        _syncUser(session);
      }
    });
  }

  Future<void> _syncUser(Session session) async {
    if (!mounted) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final navProvider = Provider.of<NavigationProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    
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
    } else {
      userProvider.syncWithSupabaseUser(session.user);
      orderProvider.fetchOrders(session.user.id);
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
