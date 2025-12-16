import 'package:flutter/material.dart';
import 'package:project_ease/app/theme/app_colors.dart';
import 'package:project_ease/screens/bottom_navigation_screens/account_screen.dart';
import 'package:project_ease/screens/bottom_navigation_screens/cart_screen.dart';
import 'package:project_ease/screens/bottom_navigation_screens/home_screen.dart';
import 'package:project_ease/screens/bottom_navigation_screens/search_screen.dart';

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({super.key});

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {

  int _selectedIndex = 0;

  List<Widget> lstBottomScreen = [
    const HomeScreen(),
    const SearchScreen(),
    const CartScreen(),
    const AccountScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: lstBottomScreen[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, 
        iconSize: 30,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        elevation: 20,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Cart"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile")
        ],
        currentIndex: _selectedIndex,
        onTap: (index){
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}