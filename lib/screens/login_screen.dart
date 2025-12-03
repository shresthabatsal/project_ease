import 'package:flutter/material.dart';
import 'package:project_ease/app/theme/app_colors.dart';
import 'package:project_ease/widgets/custom_button.dart';
import 'package:project_ease/widgets/custom_text_form_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login"), backgroundColor: AppColors.primary),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextFormField(
                controller: emailController,
                hintText: "Email",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter email";
                  }
                  if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                    return "Please enter a valid email";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CustomButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    print("Email is valid: ${emailController.text}");
                  }
                },
                text: "Login",
              ),
            ],
          ),
        ),
      ),
    );
  }
}