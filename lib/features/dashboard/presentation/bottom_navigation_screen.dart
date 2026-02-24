import 'package:flutter/material.dart';
import 'package:project_ease/features/dashboard/presentation/bottom_navigation_screens/account_screen.dart';
import 'package:project_ease/features/dashboard/presentation/bottom_navigation_screens/cart_screen.dart';
import 'package:project_ease/features/dashboard/presentation/bottom_navigation_screens/home_screen.dart';
import 'package:project_ease/features/dashboard/presentation/bottom_navigation_screens/search_screen.dart';
import 'package:project_ease/core/utils/app_fonts.dart';

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({super.key});

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  int _selectedIndex = 0;

  void _switchToSearch() {
    setState(() => _selectedIndex = 1);
  }

  @override
  Widget build(BuildContext context) {
    AppFonts.init(context);
    final bool isTablet = MediaQuery.of(context).size.width >= 600;

    final screens = [
      HomeScreen(onNavigateToSearch: _switchToSearch),
      const SearchScreen(),
      const CartScreen(),
      const AccountScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        iconSize: isTablet ? 42 : 30,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}
