import 'package:flutter/material.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("CART"),
        automaticallyImplyLeading: false,
      ),
      body: const Center(child: Text("Search Screen")),
    );
  }
}
