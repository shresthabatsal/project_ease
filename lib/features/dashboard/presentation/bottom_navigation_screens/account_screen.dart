import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/apps/routes/app_routes.dart';
import 'package:project_ease/core/widgets/custom_button.dart';
import 'package:project_ease/features/auth/presentation/pages/login_screen.dart';
import 'package:project_ease/features/auth/presentation/view_model/auth_view_model.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("ACCOUNT"),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isTablet ? 48 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// Logout Button
              CustomButton(
                text: "Logout",
                onPressed: () {
                  _showLogoutDialog(context, ref);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              // Logout Usecase
              await ref.read(authViewModelProvider.notifier).logout();

              // Navigate to login
              AppRoutes.pushAndRemoveUntil(context, const LoginScreen());
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}