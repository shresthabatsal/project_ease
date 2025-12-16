import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project_ease/app/theme/app_colors.dart';
import 'package:project_ease/common/custom_snackbar.dart';
import 'package:project_ease/screens/bottom_navigation_screen.dart';
import 'package:project_ease/screens/dashboard_screen.dart';
import 'package:project_ease/screens/signup_screen.dart';
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
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              SizedBox(
                height: 13,
                child: Image.asset(
                  "assets/images/ease_logo.png",
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 70),

              const Text(
                "Welcome Back!",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              const Text(
                "Login to your account to continue.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),

              const SizedBox(height: 25),

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
                    const SizedBox(height: 16),

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

                    const SizedBox(height: 12),

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
                            const Text("Remember me"),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

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
                                builder: (context) => const BottomNavigationScreen(),
                              ),
                            );
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don’t have an account? ",
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupScreen()));
                          },
                          child: const Text(
                            "Create one.",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade400)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text("or"),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade400)),
                      ],
                    ),

                    const SizedBox(height: 20),

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