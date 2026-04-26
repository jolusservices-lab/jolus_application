import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => OrderProvider()),
        ChangeNotifierProvider(create: (context) => NavigationProvider()),
      ],
      child: const JolusApp(),
    ),
  );
}

class JolusApp extends StatelessWidget {
  const JolusApp({super.key});

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
