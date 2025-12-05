import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project_ease/app/theme/app_colors.dart';
import 'package:project_ease/common/custom_snackbar.dart';
import 'package:project_ease/widgets/custom_button.dart';
import 'package:project_ease/widgets/custom_text_form_field.dart';

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
                "Get Started",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              const Text(
                "Sign up to get started with Ease.",
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
                              const Text("I agree to the "),
                              GestureDetector(
                                onTap: () {},
                                child: const Text(
                                  "Terms & Conditions.",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

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

                          // Proceed with signup logic
                          showAppSnackBar(
                            context: context,
                            message: "Signed in successfully!",
                            icon: Icons.check_circle_outline,
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account? ",
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Login.",
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