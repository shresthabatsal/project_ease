import 'package:flutter/material.dart';
import 'package:project_ease/apps/theme/app_colors.dart';
import 'package:project_ease/core/widgets/custom_text_form_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  void _showProfileOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),

              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(height: 16),

              ListTile(
                leading: const Icon(Icons.visibility),
                title: const Text("View Profile Picture"),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Open full screen image preview
                },
              ),

              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Choose From Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Pick image from gallery
                },
              ),

              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Take Photo"),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Open camera
                },
              ),

              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  "Remove Profile Picture",
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Remove profile picture
                },
              ),

              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("EDIT PROFILE"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Picture
            GestureDetector(
              onTap: _showProfileOptions,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.grey.shade200,
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.grey,
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.primary,
                      child: const Icon(
                        Icons.edit,
                        size: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Full Name
            CustomTextFormField(
              controller: _fullNameController,
              hintText: "Full Name",
              keyboardType: TextInputType.name,
            ),

            const SizedBox(height: 16),

            // Email
            CustomTextFormField(
              controller: _emailController,
              hintText: "Email",
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 16),

            // Password
            CustomTextFormField(
              controller: _passwordController,
              hintText: "Password",
              isPassword: true,
            ),

            const SizedBox(height: 16),

            // Phone Number
            CustomTextFormField(
              controller: _phoneController,
              hintText: "Phone Number",
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 30),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "SAVE CHANGES",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
