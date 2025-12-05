import 'package:flutter/material.dart';
import 'package:project_ease/screens/dashboard_screen.dart';
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

    _controller = VideoPlayerController.asset("assets/videos/ease_splash.mp4")
      ..initialize().then((_) {
        setState(() {}); // Refresh
        _controller.play(); // Start
        _controller.setLooping(false); // Play only once

        // Navigate after video ends
        _controller.addListener(() {
          if (_controller.value.position >= _controller.value.duration) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const DashboardScreen()));
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}