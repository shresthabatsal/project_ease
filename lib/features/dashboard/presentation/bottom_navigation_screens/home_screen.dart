import 'package:flutter/material.dart';
import 'package:project_ease/apps/theme/app_colors.dart';
import 'package:project_ease/core/utils/app_fonts.dart';
import 'package:project_ease/core/widgets/home_action_card.dart';
import 'package:project_ease/core/widgets/product_card.dart';

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
    AppFonts.init(context);
    final bool isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: isTablet ? 96 : kToolbarHeight,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Image.asset('assets/images/ease_logo.png', height: isTablet ? 20 : 10),
              const SizedBox(width: 16),

              // Texts
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'You are browsing at',
                    style: TextStyle(
                      fontSize: isTablet ? AppFonts.labelLarge : AppFonts.labelMedium,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    'Ease',
                    style: TextStyle(
                      fontSize: isTablet ? AppFonts.bodyLarge + 4 : AppFonts.bodyLarge,
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
              iconSize: isTablet ? 32 : 24,
              icon: const Icon(Icons.notifications_none, color: Colors.black),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildAdSlider(isTablet),
            const SizedBox(height: 12),
            _buildDotsIndicator(isTablet),
            const SizedBox(height: 12),

            // Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                crossAxisCount: isTablet ? 8 : 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  HomeActionCard(icon: Icons.shopping_basket_sharp, label: 'Grocery', onTap: () {}),
                  HomeActionCard(icon: Icons.checkroom, label: 'Clothing', onTap: () {}),
                  HomeActionCard(icon: Icons.cleaning_services, label: 'Household', onTap: () {}),
                  HomeActionCard(icon: Icons.devices, label: 'Electronics', onTap: () {}),
                  HomeActionCard(icon: Icons.spa, label: 'Care', onTap: () {}),
                  HomeActionCard(icon: Icons.health_and_safety, label: 'Health', onTap: () {}),
                  HomeActionCard(icon: Icons.edit, label: 'Stationery', onTap: () {}),
                  HomeActionCard(icon: Icons.child_friendly, label: 'Baby', onTap: () {}),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'FOR YOU',
                  style: TextStyle(
                    fontSize: AppFonts.labelLarge,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isTablet ? 4 : 2,
                  mainAxisExtent: isTablet ? 318 : 248,
                ),
                children: [
                  ProductCard(
                    imagePath: 'assets/images/coat.png',
                    name: 'Product 1',
                    price: 'NPR 700',
                    isFavorite: false,
                    onFavoriteTap: () {},
                    onTap: () {},
                  ),
                  ProductCard(
                    imagePath: 'assets/images/coat.png',
                    name: 'Product 2',
                    price: 'NPR 60',
                    isFavorite: false,
                    onFavoriteTap: () {},
                    onTap: () {},
                  ),
                  ProductCard(
                    imagePath: 'assets/images/coat.png',
                    name: 'Product 3',
                    price: 'NPR 890',
                    isFavorite: false,
                    onFavoriteTap: () {},
                    onTap: () {},
                  ),
                  ProductCard(
                    imagePath: 'assets/images/coat.png',
                    name: 'Product 4',
                    price: 'NPR 200',
                    isFavorite: false,
                    onFavoriteTap: () {},
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdSlider(bool isTablet) {
    final List<String> images = isTablet
      ? [
          'assets/images/tab_ad.png',
          'assets/images/tab_ad.png',
          'assets/images/tab_ad.png',
        ]
      : adImages;
  return SizedBox(
    height: isTablet ? 240 : 160,
    width: double.infinity,
    child: PageView.builder(
      controller: _pageController,
      itemCount: images.length,
      onPageChanged: (index) => setState(() => _currentPage = index),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              images[index],
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
        );
      },
    ),
  );
}

  Widget _buildDotsIndicator(bool isTablet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        adImages.length,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? (isTablet ? 12 : 8) : (isTablet ? 8 : 6),
          height: _currentPage == index ? (isTablet ? 12 : 8) : (isTablet ? 8 : 6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index ? AppColors.primary : Colors.grey,
          ),
        ),
      ),
    );
  }
}