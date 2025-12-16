import 'package:flutter/material.dart';
import 'package:project_ease/screens/splash_screen.dart';
import 'package:project_ease/theme/theme_data.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: getApplicationTheme(),
      debugShowCheckedModeBanner: false,
      home: SplashScreen()
    );
  }
}