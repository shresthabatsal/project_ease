import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project_ease/theme/app_colors.dart';
import 'package:project_ease/common/custom_snackbar.dart';
import 'package:project_ease/screens/bottom_navigation_screen.dart';
import 'package:project_ease/screens/signup_screen.dart';
import 'package:project_ease/utils/app_fonts.dart';
import 'package:project_ease/widgets/custom_button.dart';
import 'package:project_ease/widgets/custom_text_form_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool rememberMe = false;

  @override
  Widget build(BuildContext context) {
    AppFonts.init(context);
    final bool isTablet = MediaQuery.of(context).size.width >= 600;

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
              SizedBox(
                height: isTablet ? 26 : 13,
                child: Image.asset(
                  "assets/images/ease_logo.png",
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: isTablet ? 140 : 70),
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
                          onTap: () {},
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
                    CustomButton(
                      text: "Login",
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          showAppSnackBar(
                            context: context,
                            message: "Logged in successfully!",
                            icon: Icons.check_circle,
                          );
                          Future.delayed(const Duration(seconds: 2), () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const BottomNavigationScreen(),
                              ),
                            );
                          });
                        }
                      },
                    ),
                    SizedBox(height: isTablet ? 40 : 20),
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
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignupScreen(),
                              ),
                            );
                          },
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
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade400)),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 20 : 10,
                          ),
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
                    CustomButton(
                      leadingIcon: FontAwesomeIcons.google,
                      text: "Continue with Google",
                      color: Colors.white,
                      onPressed: () {},
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