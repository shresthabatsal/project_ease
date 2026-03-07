import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/apps/routes/app_routes.dart';
import 'package:project_ease/core/services/storage/user_service_session.dart';
import 'package:project_ease/features/auth/presentation/pages/login_screen.dart';
import 'package:project_ease/features/dashboard/presentation/bottom_navigation_screen.dart';
import 'package:project_ease/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  late VideoPlayerController _controller;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset("assets/videos/ease_splash.mp4");
    _controller.initialize().then((_) {
      setState(() {});
      _controller.play();
      _controller.setLooping(false);

      _controller.addListener(() {
        if (_controller.value.position >= _controller.value.duration) {
          _navigateNext();
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _navigateNext() async {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    final userSessionService = ref.read(userSessionServiceProvider);
    final isLoggedIn = userSessionService.isLoggedIn();

    if (isLoggedIn) {
      AppRoutes.pushReplacement(context, const BottomNavigationScreen());
      return;
    }

    // Not logged in, show onboarding only on first ever launch
    final firstLaunch = await isFirstLaunch();
    if (!mounted) return;

    AppRoutes.pushReplacement(
      context,
      firstLaunch ? const OnboardingScreen() : const LoginScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: _controller.value.isInitialized
            ? ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: screenWidth * 0.8,
                  maxHeight: screenHeight * 0.5,
                ),
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
