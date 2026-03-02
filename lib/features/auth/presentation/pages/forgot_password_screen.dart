import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/apps/theme/app_colors.dart';
import 'package:project_ease/core/utils/app_fonts.dart';
import 'package:project_ease/core/utils/snackbar_utils.dart';
import 'package:project_ease/core/widgets/custom_button.dart';
import 'package:project_ease/core/widgets/custom_text_form_field.dart';
import 'package:project_ease/features/auth/presentation/state/auth_state.dart';
import 'package:project_ease/features/auth/presentation/view_model/auth_view_model.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendResetEmail() async {
    if (_formKey.currentState!.validate()) {
      await ref
          .read(authViewModelProvider.notifier)
          .forgotPassword(email: _emailController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    AppFonts.init(context);
    final bool isTablet = MediaQuery.of(context).size.width >= 600;
    final authState = ref.watch(authViewModelProvider);

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.passwordResetSent) {
        setState(() => _emailSent = true);
      } else if (next.status == AuthStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(context, next.errorMessage!);
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isTablet ? 48 : 24),
          child: _emailSent
              ? _buildSuccessView(isTablet)
              : _buildFormView(isTablet, authState),
        ),
      ),
    );
  }

  Widget _buildFormView(bool isTablet, AuthState authState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: isTablet ? 60 : 40),

        // Icon
        Container(
          width: isTablet ? 100 : 72,
          height: isTablet ? 100 : 72,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.lock_reset_rounded,
            size: isTablet ? 52 : 38,
            color: AppColors.primary,
          ),
        ),

        SizedBox(height: isTablet ? 40 : 24),

        Text(
          "Forgot Password?",
          style: TextStyle(
            fontSize: isTablet ? AppFonts.titleLarge : AppFonts.titleMedium,
            fontWeight: FontWeight.bold,
          ),
        ),

        SizedBox(height: isTablet ? 16 : 8),

        Text(
          "Enter your email address and we'll send you a link to reset your password.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isTablet ? AppFonts.bodyLarge : AppFonts.bodyMedium,
            color: Colors.grey,
            height: 1.5,
          ),
        ),

        SizedBox(height: isTablet ? 50 : 32),

        Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextFormField(
                controller: _emailController,
                hintText: "Email Address",
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Email is required.";
                  }
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!emailRegex.hasMatch(value)) {
                    return "Enter a valid email address.";
                  }
                  return null;
                },
              ),

              SizedBox(height: isTablet ? 40 : 24),

              CustomButton(
                text: "Send Reset Link",
                isLoading: authState.status == AuthStatus.loading,
                onPressed: _handleSendResetEmail,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessView(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: isTablet ? 60 : 40),

        Container(
          width: isTablet ? 100 : 72,
          height: isTablet ? 100 : 72,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.mark_email_read_rounded,
            size: isTablet ? 52 : 38,
            color: Colors.green,
          ),
        ),

        SizedBox(height: isTablet ? 40 : 24),

        Text(
          "Check Your Email",
          style: TextStyle(
            fontSize: isTablet ? AppFonts.titleLarge : AppFonts.titleMedium,
            fontWeight: FontWeight.bold,
          ),
        ),

        SizedBox(height: isTablet ? 16 : 8),

        Text(
          "We've sent a password reset link to\n${_emailController.text.trim()}",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isTablet ? AppFonts.bodyLarge : AppFonts.bodyMedium,
            color: Colors.grey,
            height: 1.6,
          ),
        ),

        SizedBox(height: isTablet ? 12 : 8),

        Text(
          "Didn't receive the email? Check your spam folder or try again.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isTablet ? AppFonts.bodyMedium : AppFonts.bodySmall,
            color: Colors.grey.shade400,
            height: 1.5,
          ),
        ),

        SizedBox(height: isTablet ? 40 : 32),

        CustomButton(
          text: "Back to Login",
          onPressed: () => Navigator.of(context).pop(),
        ),

        SizedBox(height: isTablet ? 20 : 12),

        TextButton(
          onPressed: () => setState(() => _emailSent = false),
          child: Text(
            "Try a different email",
            style: TextStyle(
              color: AppColors.primary,
              fontSize: isTablet ? AppFonts.bodyMedium : AppFonts.bodySmall,
            ),
          ),
        ),
      ],
    );
  }
}
