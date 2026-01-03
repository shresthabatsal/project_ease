import 'package:flutter/material.dart';
import 'package:project_ease/apps/routes/app_routes.dart';
import 'package:project_ease/apps/theme/app_colors.dart';
import 'package:project_ease/features/auth/presentation/pages/login_screen.dart';
import 'package:project_ease/core/utils/app_fonts.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _slides = [
    {
      "title": "Shop with Ease",
      "subtitle":
          "Browse stores, explore products, and\nplace orders effortlessly.",
      "image": "assets/images/onboarding_1.png",
    },
    {
      "title": "Smart Shopping",
      "subtitle":
          "Track availability, add items to your cart, and\ncomplete your order in just a few taps.",
      "image": "assets/images/onboarding_2.png",
    },
    {
      "title": "Fast Pickup",
      "subtitle":
          "Get a unique code and collect your order\nquickly and conveniently.",
      "image": "assets/images/onboarding_3.png",
    },
  ];

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      AppRoutes.pushReplacement(context, const LoginScreen());
    }
  }

  void _skip() {
    AppRoutes.pushReplacement(context, const LoginScreen());
  }

  @override
  Widget build(BuildContext context) {
    AppFonts.init(context);
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  final slide = _slides[index];

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      double imageHeight = constraints.maxHeight * 0.45;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            Text(
                              slide['title']!,
                              style: TextStyle(
                                fontSize: AppFonts.titleLarge,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const SizedBox(height: 8),

                            const SizedBox(height: 8),

                            // Subtitle
                            Text(
                              slide['subtitle']!,
                              style: TextStyle(
                                fontSize: AppFonts.bodyMedium,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Expanded(
                              child: Center(
                                child: Image.asset(
                                  slide['image']!,
                                  height: imageHeight,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Bottom Navigation
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Skip Button
                  TextButton(
                    onPressed: _skip,
                    child: Text(
                      "Skip",
                      style: TextStyle(color: Colors.grey.shade600,
                      fontSize: AppFonts.bodyLarge,),
                    ),
                  ),

                  // Indicators
                  Row(
                    children: List.generate(_slides.length, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 12 : 8,
                        height: _currentPage == index ? 12 : 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? AppColors.primary
                              : Colors.grey,
                        ),
                      );
                    }),
                  ),

                  // Next Button
                  TextButton(
                    onPressed: _nextPage,
                    child: Text(
                      _currentPage == _slides.length - 1 ? "Done" : "Next",
                      style: TextStyle(
                        fontSize: AppFonts.bodyLarge,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
