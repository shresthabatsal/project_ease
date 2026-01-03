  import 'package:flutter/material.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project_ease/apps/routes/app_routes.dart';
  import 'package:project_ease/apps/theme/app_colors.dart';
  import 'package:project_ease/core/utils/snackbar_utils.dart';
  import 'package:project_ease/features/auth/presentation/pages/login_screen.dart';
  import 'package:project_ease/core/widgets/custom_button.dart';
  import 'package:project_ease/core/widgets/custom_text_form_field.dart';
  import 'package:project_ease/core/utils/app_fonts.dart';
  import 'package:project_ease/features/auth/presentation/state/auth_state.dart';
  import 'package:project_ease/features/auth/presentation/view_model/auth_view_model.dart';

  class SignupScreen extends ConsumerStatefulWidget {
    const SignupScreen({super.key});

    @override
    ConsumerState<SignupScreen> createState() => _SignupScreenState();
  }

  class _SignupScreenState extends ConsumerState<SignupScreen> {
    final _formKey = GlobalKey<FormState>();

    final TextEditingController fullNameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();

    bool agreeTerms = false;

    @override
    void dispose() {
      fullNameController.dispose();
      phoneController.dispose();
      emailController.dispose();
      passwordController.dispose();
      confirmPasswordController.dispose();
      super.dispose();
    }

    void _clearForm() {
      _formKey.currentState?.reset();

      fullNameController.clear();
      phoneController.clear();
      emailController.clear();
      passwordController.clear();
      confirmPasswordController.clear();

      setState(() {
        agreeTerms = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusManager.instance.primaryFocus?.unfocus();
      });
    }


    Future<void> _handleSignup() async {
      if (!agreeTerms) {
        SnackbarUtils.showWarning(
          context,
          "You must agree to the Terms & Conditions",
        );
        return;
      }

      if (_formKey.currentState!.validate()) {
        await ref
            .read(authViewModelProvider.notifier)
            .register(
              fullName: fullNameController.text,
              email: emailController.text,
              phoneNumber: phoneController.text,
              password: passwordController.text,
            );
      }
    }

    @override
    Widget build(BuildContext context) {
      AppFonts.init(context);
      final bool isTablet = MediaQuery.of(context).size.width >= 600;

      final authState =  ref.watch(authViewModelProvider);

      // Auth State
      ref.listen<AuthState>(authViewModelProvider, (previous, next) {
        if (next.status == AuthStatus.error) {
          SnackbarUtils.showError(
            context,
            next.errorMessage ?? "Registration Failed.",
          );
        } else if (next.status == AuthStatus.registered) {
          SnackbarUtils.showSuccess(context, "Registration Successful.");
          _clearForm();
        }
      });

      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.white),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isTablet ? 48 : 24),
            child: Center(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // SizedBox(height: isTablet ? 40 : 20),
              
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
                        fontSize: isTablet
                            ? AppFonts.bodyLarge
                            : AppFonts.bodyMedium,
                        color: Colors.grey,
                      ),
                    ),
              
                    SizedBox(height: isTablet ? 50 : 25),
              
                    // Full Name
                    CustomTextFormField(
                      controller: fullNameController,
                      hintText: "Full Name",
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Full name is required.";
                        if (value.length < 3) return "Name must be at least 3 characters.";
                        return null;
                      },
                    ),
              
                    SizedBox(height: isTablet ? 32 : 16),
              
                    // Phone Number
                    CustomTextFormField(
                      controller: phoneController,
                      hintText: "Phone Number",
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Phone number is required.";
                        if (value.length != 10) return "Phone number must be 10 digits.";
                        return null;
                      },
                    ),
              
                    SizedBox(height: isTablet ? 32 : 16),
              
                    // Email
                    CustomTextFormField(
                      controller: emailController,
                      hintText: "Email",
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Email is required.";
                        return null;
                      },
                    ),
              
                    SizedBox(height: isTablet ? 32 : 16),
              
                    // Password
                    CustomTextFormField(
                      controller: passwordController,
                      hintText: "Password",
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Password is required.";
                        if (value.length < 6) return "Password must be at least 6 characters.";
                        return null;
                      },
                    ),
              
                    SizedBox(height: isTablet ? 32 : 16),
              
                    // Confirm Password
                    CustomTextFormField(
                      controller: confirmPasswordController,
                      hintText: "Confirm Password",
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Confirm password is required.";
                        if (value != passwordController.text)   return "Passwords do not match.";
                        return null;
                      },
                    ),
              
                    SizedBox(height: isTablet ? 24 : 12),
              
                    // Terms
                    Row(
                      children: [
                        Checkbox(
                          value: agreeTerms,
                          activeColor: AppColors.primary,
                          onChanged: (value) =>
                              setState(() => agreeTerms = value ?? false),
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
              
                    // Sign Up Button
                    CustomButton(
                      text: "Sign Up", 
                      onPressed: _handleSignup,
                      isLoading: authState.status == AuthStatus.loading),
              
                    SizedBox(height: isTablet ? 40 : 20),
              
                    // Login Link
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
                          onTap: () => AppRoutes.push(context, const LoginScreen()),
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
              
                    // Divider
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
              
                    // Continue With Google
                    CustomButton(
                      leadingIcon: FontAwesomeIcons.google,
                      text: "Continue with Google",
                      color: Colors.white,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
  } 