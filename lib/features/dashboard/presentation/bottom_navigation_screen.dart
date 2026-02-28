import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/apps/theme/app_colors.dart';
import 'package:project_ease/core/utils/app_fonts.dart';
import 'package:project_ease/core/utils/shake_detector.dart';
import 'package:project_ease/features/cart/presentation/state/cart_state.dart';
import 'package:project_ease/features/dashboard/presentation/bottom_navigation_screens/account_screen.dart';
import 'package:project_ease/features/dashboard/presentation/bottom_navigation_screens/cart_screen.dart';
import 'package:project_ease/features/dashboard/presentation/bottom_navigation_screens/home_screen.dart';
import 'package:project_ease/features/dashboard/presentation/bottom_navigation_screens/my_orders_screen.dart';
import 'package:project_ease/features/dashboard/presentation/bottom_navigation_screens/order_detail_screen.dart';
import 'package:project_ease/features/dashboard/presentation/bottom_navigation_screens/search_screen.dart';
import 'package:project_ease/features/order/presentation/view_model/order_view_model.dart';

class BottomNavigationScreen extends ConsumerStatefulWidget {
  const BottomNavigationScreen({super.key});

  @override
  ConsumerState<BottomNavigationScreen> createState() =>
      _BottomNavigationScreenState();
}

class _BottomNavigationScreenState
    extends ConsumerState<BottomNavigationScreen> {
  int _selectedIndex = 0;
  late final ShakeDetector _shakeDetector;

  @override
  void initState() {
    super.initState();
    _shakeDetector = ShakeDetector(onShake: _onShake);
    _shakeDetector.start();

    Future.microtask(
      () => ref.read(orderViewModelProvider.notifier).loadOrders(),
    );
  }

  @override
  void dispose() {
    _shakeDetector.stop();
    super.dispose();
  }

  // Shake handler

  Future<void> _onShake() async {
    if (!mounted) return;

    HapticFeedback.mediumImpact();

    final orders = ref.read(orderViewModelProvider).orders;

    if (orders.isEmpty) {
      await ref.read(orderViewModelProvider.notifier).loadOrders();
    }

    if (!mounted) return;

    final readyOrders = ref
        .read(orderViewModelProvider)
        .orders
        .where((o) => o.status == 'READY_FOR_COLLECTION')
        .toList();

    if (readyOrders.length == 1) {
      // Exactly one ready order, go straight to its detail screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OrderDetailScreen(orderId: readyOrders.first.orderId),
        ),
      );
    } else if (readyOrders.length > 1) {
      // Multiple ready orders, open My Orders pre-filtered
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              const MyOrdersScreen(initialFilter: 'READY_FOR_COLLECTION'),
        ),
      );
    } else {
      // No ready orders, open My Orders with default view
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const MyOrdersScreen()));
    }
  }

  void _switchToSearch() => setState(() => _selectedIndex = 1);

  @override
  Widget build(BuildContext context) {
    AppFonts.init(context);
    final bool isTablet = MediaQuery.of(context).size.width >= 600;
    final cartCount = ref.watch(
      cartViewModelProvider.select((s) => s.totalItems),
    );

    final screens = [
      HomeScreen(onNavigateToSearch: _switchToSearch),
      const SearchScreen(),
      const CartScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        iconSize: isTablet ? 42 : 30,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_cart_outlined),
                if (cartCount > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        cartCount > 99 ? '99+' : '$cartCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}
