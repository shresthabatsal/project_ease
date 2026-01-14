import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/apps/routes/app_routes.dart';
import 'package:project_ease/core/services/hive/storage/user_service_session.dart';
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

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset("assets/videos/ease_splash.mp4");
      _controller.initialize().then((_) {
      setState(() {}); // Refresh the UI
      _controller.play(); // Start playback
      _controller.setLooping(false); // Play only once

        // Navigate after video ends
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    double videoWidth = screenWidth * 0.8;
    double videoHeight = screenHeight * 0.5;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: _controller.value.isInitialized
            ? ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: videoWidth,
                  maxHeight: videoHeight,
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
  
  void _navigateNext() {
  if (!mounted) return;

  final userSessionService = ref.read(userSessionServiceProvider);
  final isLoggedIn = userSessionService.isLoggedIn();

  if (isLoggedIn) {
    AppRoutes.pushReplacement(context, const BottomNavigationScreen());
  } else {
    AppRoutes.pushReplacement(context, const OnboardingScreen());
  }
}

}