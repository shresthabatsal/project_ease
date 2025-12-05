import 'package:flutter/material.dart';
import 'package:project_ease/screens/onboarding_screen.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OnboardingScreen()),
            );
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
}