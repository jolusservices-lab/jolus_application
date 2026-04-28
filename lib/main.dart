import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_links/app_links.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/cart_provider.dart';
import 'core/providers/user_provider.dart';
import 'core/providers/order_provider.dart';
import 'core/providers/navigation_provider.dart';
import 'presentation/screens/auth/splash_screen.dart';
import 'core/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

  void _setupDeepLinks() {
    // Escucha enlaces entrantes para Windows
    _appLinks.uriLinkStream.listen((uri) {
      print('DEBUG DEEP LINK: Enlace recibido: $uri');
      // Supabase captura automáticamente este enlace si la instancia está activa
    });
  }

  void _setupAuthListener() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      print('DEBUG AUTH: Evento detectado: $event');

      if ((event == AuthChangeEvent.signedIn || event == AuthChangeEvent.initialSession) && session != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            final userProvider = Provider.of<UserProvider>(context, listen: false);
            userProvider.syncWithSupabaseUser(session.user);
            print('DEBUG AUTH: Usuario sincronizado tras login exitoso');
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jolus Services',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
