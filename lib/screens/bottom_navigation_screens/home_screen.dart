import 'package:flutter/material.dart';
import 'package:project_ease/theme/app_colors.dart';
import 'package:project_ease/widgets/home_action_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> adImages = [
    'assets/images/ad.png',
    'assets/images/ad.png',
    'assets/images/ad.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              // Logo
              Image.asset('assets/images/ease_logo.png', height: 10),

              const SizedBox(width: 16),

              // Texts
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'You are browsing at',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    'Ease',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Notification Icon
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.black),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          _buildAdSlider(),

          const SizedBox(height: 12),
          _buildDotsIndicator(),

          const SizedBox(height: 12),

          // Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                HomeActionCard(
                  icon: Icons.shopping_basket_sharp,
                  label: 'Grocery',
                  onTap: () {},
                ),
                HomeActionCard(
                  icon: Icons.checkroom,
                  label: 'Clothing',
                  onTap: () {},
                ),
                HomeActionCard(
                  icon: Icons.cleaning_services,
                  label: 'Household',
                  onTap: () {},
                ),
                HomeActionCard(
                  icon: Icons.devices,
                  label: 'Electronics',
                  onTap: () {},
                ),
                HomeActionCard(icon: Icons.spa, label: 'Care', onTap: () {}),
                HomeActionCard(
                  icon: Icons.health_and_safety,
                  label: 'Health',
                  onTap: () {},
                ),
                HomeActionCard(
                  icon: Icons.edit,
                  label: 'Stationery',
                  onTap: () {},
                ),
                HomeActionCard(
                  icon: Icons.child_friendly,
                  label: 'Baby',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Ad Slider
  Widget _buildAdSlider() {
    return SizedBox(
      height: 160,
      child: PageView.builder(
        controller: _pageController,
        itemCount: adImages.length,
        onPageChanged: (index) {
          setState(() => _currentPage = index);
        },
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(adImages[index], fit: BoxFit.cover),
            ),
          );
        },
      ),
    );
  }

  // Dots Indicator
  Widget _buildDotsIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        adImages.length,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 8 : 6,
          height: _currentPage == index ? 8 : 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index ? AppColors.primary : Colors.grey,
          ),
        ),
      ),
    );
  }
}