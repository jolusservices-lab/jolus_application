import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/providers/navigation_provider.dart';
import '../../core/providers/cart_provider.dart';
import '../screens/home_screen.dart';
import '../screens/services_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/history_screen.dart';
import '../screens/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  final int initialIndex;
  const MainNavigation({super.key, this.initialIndex = 0});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to avoid calling notifyListeners during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialIndex != 0) {
        context.read<NavigationProvider>().setSelectedIndex(widget.initialIndex);
      }
    });
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const ServicesScreen(),
    const CartScreen(),
    const HistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<NavigationProvider>();
    final cartProvider = context.watch<CartProvider>();
    final int cartItemsCount = cartProvider.itemCount;

    return Scaffold(
      body: IndexedStack(
        index: navProvider.selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navProvider.selectedIndex,
        onDestinationSelected: (index) => navProvider.setSelectedIndex(index),
        indicatorColor: JolusColors.primary.withValues(alpha: 0.1),
        destinations: [
          const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: JolusColors.primary), label: 'Inicio'),
          const NavigationDestination(icon: Icon(Icons.apps_outlined), selectedIcon: Icon(Icons.apps, color: JolusColors.primary), label: 'Servicios'),
          NavigationDestination(
            icon: Badge(
              label: Text('$cartItemsCount'),
              isLabelVisible: cartItemsCount > 0,
              backgroundColor: JolusColors.primary,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            selectedIcon: Badge(
              label: Text('$cartItemsCount'),
              isLabelVisible: cartItemsCount > 0,
              backgroundColor: JolusColors.primary,
              child: const Icon(Icons.shopping_cart, color: JolusColors.primary),
            ),
            label: 'Carrito',
          ),
          const NavigationDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history, color: JolusColors.primary), label: 'Historial'),
          const NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person, color: JolusColors.primary), label: 'Perfil'),
        ],
      ),
    );
  }
}
