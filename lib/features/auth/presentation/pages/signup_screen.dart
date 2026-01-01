import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project_ease/apps/theme/app_colors.dart';
import 'package:project_ease/core/widgets/custom_snackbar.dart';
import 'package:project_ease/features/auth/presentation/pages/login_screen.dart';
import 'package:project_ease/core/widgets/custom_button.dart';
import 'package:project_ease/core/widgets/custom_text_form_field.dart';
import 'package:project_ease/core/utils/app_fonts.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool agreeTerms = false;

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
                "Get Started",
                style: TextStyle(
                  fontSize: isTablet
                      ? AppFonts.titleLarge
                      : AppFonts.titleMedium,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: isTablet ? 16 : 8),
              Text(
                "Sign up to get started with Ease.",
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
                      children: [
                        Checkbox(
                          value: agreeTerms,
                          activeColor: AppColors.primary,
                          onChanged: (value) {
                            setState(() {
                              agreeTerms = value ?? false;
                            });
                          },
                        ),
                        Expanded(
                          child: Wrap(
                            children: [
                              Text(
                                "I agree to the ",
                                style: TextStyle(
                                  fontSize: isTablet
                                      ? AppFonts.bodyMedium
                                      : AppFonts.bodySmall,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: Text(
                                  "Terms & Conditions.",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: isTablet
                                        ? AppFonts.bodyMedium
                                        : AppFonts.bodySmall,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isTablet ? 40 : 20),
                    CustomButton(
                      text: "Sign Up",
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (!agreeTerms) {
                            showAppSnackBar(
                              context: context,
                              message:
                                  "You must agree to the Terms & Conditions",
                              icon: Icons.warning_amber_rounded,
                            );
                            return;
                          }

                          showAppSnackBar(
                            context: context,
                            message: "Signed in successfully!",
                            icon: Icons.check_circle_outline,
                          );

                          Future.delayed(const Duration(seconds: 2), () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
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
                          "Already have an account? ",
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: isTablet
                                ? AppFonts.bodyMedium
                                : AppFonts.bodySmall,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: Text(
                            "Login.",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: isTablet
                                  ? AppFonts.bodyMedium
                                  : AppFonts.bodySmall,
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