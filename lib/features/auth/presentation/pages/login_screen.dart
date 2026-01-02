import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project_ease/apps/theme/app_colors.dart';
import 'package:project_ease/core/utils/snackbar_utils.dart';
import 'package:project_ease/core/utils/app_fonts.dart';
import 'package:project_ease/core/widgets/custom_button.dart';
import 'package:project_ease/core/widgets/custom_text_form_field.dart';
import 'package:project_ease/features/auth/presentation/pages/signup_screen.dart';
import 'package:project_ease/features/auth/presentation/state/auth_state.dart';
import 'package:project_ease/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:project_ease/features/dashboard/presentation/bottom_navigation_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool rememberMe = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      await ref
          .read(authViewModelProvider.notifier)
          .login(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );
    }
  }

  void _navigateToSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignupScreen()),
    );
  }

  void _handleForgotPassword() {}

  void _handleGoogleSignIn() {}

  @override
  Widget build(BuildContext context) {
    AppFonts.init(context);
    final bool isTablet = MediaQuery.of(context).size.width >= 600;

    final authState = ref.watch(authViewModelProvider);

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const BottomNavigationScreen(),
          ),
        );
      } else if (next.status == AuthStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(context, next.errorMessage!);
      }
    });

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isTablet ? 48 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: isTablet ? 40 : 20),

              // Logo
              SizedBox(
                height: isTablet ? 26 : 13,
                child: Image.asset(
                  "assets/images/ease_logo.png",
                  fit: BoxFit.contain,
                ),
              ),

              SizedBox(height: isTablet ? 140 : 70),

              // Header
              Text(
                "Welcome Back!",
                style: TextStyle(
                  fontSize: isTablet
                      ? AppFonts.titleLarge
                      : AppFonts.titleMedium,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: isTablet ? 16 : 8),
              Text(
                "Login to your account to continue.",
                style: TextStyle(
                  fontSize: isTablet ? AppFonts.bodyLarge : AppFonts.bodyMedium,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: isTablet ? 50 : 25),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Email Field
                    CustomTextFormField(
                      controller: emailController,
                      hintText: "Email",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Email is required.";
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: isTablet ? 32 : 16),

                    // Password Field
                    CustomTextFormField(
                      controller: passwordController,
                      hintText: "Password",
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Password is required.";
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: isTablet ? 24 : 12),

                    // Remember Me and Forgot Password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: rememberMe,
                              activeColor: AppColors.primary,
                              onChanged: (value) {
                                setState(() {
                                  rememberMe = value ?? false;
                                });
                              },
                            ),
                            Text(
                              "Remember me",
                              style: TextStyle(
                                fontSize: isTablet
                                    ? AppFonts.bodyMedium
                                    : AppFonts.labelMedium,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: _handleForgotPassword,
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(
                              fontSize: isTablet
                                  ? AppFonts.bodyMedium
                                  : AppFonts.labelMedium,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: isTablet ? 40 : 20),

                    // Login Button
                    CustomButton(
                      text: "Login",
                      isLoading: authState.status == AuthStatus.loading,
                      onPressed: _handleLogin,
                    ),

                    SizedBox(height: isTablet ? 40 : 20),

                    // Signup Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don’t have an account? ",
                          style: TextStyle(
                            fontSize: isTablet
                                ? AppFonts.bodyMedium
                                : AppFonts.bodySmall,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        GestureDetector(
                          onTap: _navigateToSignup,
                          child: Text(
                            "Create one.",
                            style: TextStyle(
                              fontSize: isTablet
                                  ? AppFonts.bodyMedium
                                  : AppFonts.bodySmall,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: isTablet ? 40 : 20),

                    // Divider
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade400)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 10),
                          child: Text(
                            "or",
                            style: TextStyle(
                              fontSize: isTablet
                                  ? AppFonts.bodyMedium
                                  : AppFonts.labelMedium,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade400)),
                      ],
                    ),

                    SizedBox(height: isTablet ? 40 : 20),

                    // Continue With Google Button
                    CustomButton(
                      leadingIcon: FontAwesomeIcons.google,
                      text: "Continue with Google",
                      color: Colors.white,
                      onPressed: _handleGoogleSignIn,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}