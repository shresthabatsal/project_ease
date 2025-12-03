import 'package:flutter/material.dart';
import 'package:project_ease/screens/dashboard_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: "Montserrat"
      ),
      debugShowCheckedModeBanner: false,
      home: DashboardScreen()
    );
  }
}