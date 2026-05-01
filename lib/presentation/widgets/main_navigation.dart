import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/providers/navigation_provider.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/providers/user_provider.dart';
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
    final userProvider = context.watch<UserProvider>();
    final int cartItemsCount = cartProvider.itemCount;

    return Scaffold(
      body: IndexedStack(
        index: navProvider.selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        height: 60 + MediaQuery.of(context).padding.bottom,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, -1),
            ),
          ],
          border: Border(
            top: BorderSide(color: Colors.grey.withOpacity(0.15), width: 0.5),
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.home_outlined, Icons.home_rounded, navProvider),
                  _buildNavItem(1, Icons.grid_view_outlined, Icons.grid_view_rounded, navProvider),
                  _buildNavItem(2, Icons.storefront_outlined, Icons.storefront_rounded, navProvider, badgeCount: cartItemsCount),
                  _buildNavItem(3, Icons.history_outlined, Icons.history_rounded, navProvider),
                  _buildProfileItem(4, userProvider, navProvider),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData unselectedIcon, IconData selectedIcon, NavigationProvider provider, {int badgeCount = 0}) {
    final isSelected = provider.selectedIndex == index;
    final color = isSelected ? JolusColors.primaryBlue : const Color(0xFF65676B);
    
    return Expanded(
      child: GestureDetector(
        onTap: () => provider.setSelectedIndex(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            const Spacer(),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected ? selectedIcon : unselectedIcon,
                  size: 28,
                  color: color,
                ),
                if (badgeCount > 0)
                  Positioned(
                    right: -6,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const Spacer(),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 3,
              width: isSelected ? 40 : 0,
              decoration: BoxDecoration(
                color: JolusColors.primaryBlue,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(3),
                  topRight: Radius.circular(3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(int index, UserProvider user, NavigationProvider provider) {
    final isSelected = provider.selectedIndex == index;
    final photoUrl = user.photoUrl;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => provider.setSelectedIndex(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: isSelected ? Border.all(color: JolusColors.primaryBlue, width: 2) : null,
              ),
              child: CircleAvatar(
                radius: 14,
                backgroundColor: const Color(0xFFE4E6EB),
                backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                    ? NetworkImage(photoUrl) 
                    : null,
                child: (photoUrl == null || photoUrl.isEmpty)
                    ? const Icon(Icons.person, size: 20, color: Color(0xFF65676B)) 
                    : null,
              ),
            ),
            const Spacer(),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 3,
              width: isSelected ? 40 : 0,
              decoration: BoxDecoration(
                color: JolusColors.primaryBlue,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(3),
                  topRight: Radius.circular(3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
