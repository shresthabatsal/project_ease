import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("ACCOUNT"),
        automaticallyImplyLeading: false,
      ),
      body: const Center(child: Text("Account Screen")),
    );
  }
}