import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:project_ease/apps/theme/app_colors.dart';
import 'package:project_ease/core/api/api_endpoints.dart';
import 'package:project_ease/core/utils/snackbar_utils.dart';
import 'package:project_ease/core/widgets/custom_text_form_field.dart';
import 'package:project_ease/features/auth/domain/entities/auth_entity.dart';
import 'package:project_ease/features/profile/presentation/state/profile_state.dart';
import 'package:project_ease/features/profile/presentation/view_model/profile_view_model.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileViewModelProvider.notifier).loadProfile();
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<bool> _requestPermission(Permission permission) async {
    final status = await permission.status;

    if (status.isGranted) return true;

    if (status.isDenied) {
      final result = await permission.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog();
      return false;
    }

    return false;
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Permission Required"),
        content: const Text(
          "Please enable camera or gallery permission from settings to continue.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFromCamera() async {
    final hasPermission = await _requestPermission(Permission.camera);
    if (!hasPermission) return;

    final XFile? photo = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (photo != null) {
      await ref
          .read(profileViewModelProvider.notifier)
          .uploadProfilePicture(File(photo.path));
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        await ref
            .read(profileViewModelProvider.notifier)
            .uploadProfilePicture(File(image.path));
      }
    } catch (_) {
      if (mounted) {
        SnackbarUtils.showWarning(context, "Unable to access gallery");
      }
    }
  }

  void _confirmRemovePhoto() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove Profile Picture"),
        content: const Text(
          "Are you sure you want to remove your profile photo?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(profileViewModelProvider.notifier)
                  .clearUploadedPictureUrl();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Remove"),
          ),
        ],
      ),
    );
  }

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
                title: const Text("View profile picture"),
                onTap: () {
                  Navigator.pop(context);
                  final currentUrl =
                      ref
                          .read(profileViewModelProvider)
                          .uploadedProfilePictureUrl ??
                      ref
                          .read(profileViewModelProvider)
                          .profile
                          ?.profilePicture;
                  if (currentUrl != null && currentUrl.isNotEmpty) {
                    showDialog(
                      context: context,
                      builder: (_) => Dialog(
                        child: Image.network(currentUrl, fit: BoxFit.cover),
                      ),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Choose from gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Take photo"),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  "Remove profile picture",
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmRemovePhoto();
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
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileViewModelProvider);

    ref.listen<ProfileState>(profileViewModelProvider, (previous, next) {
      if (next.status == ProfileStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(context, next.errorMessage!);
      }

      // Prefill fields when profile is loaded
      if (next.status == ProfileStatus.loaded && next.profile != null) {
        final profile = next.profile!;

        if (_fullNameController.text.isEmpty) {
          _fullNameController.text = profile.fullName;
        }
        if (_emailController.text.isEmpty) {
          _emailController.text = profile.email;
        }
        if (_phoneController.text.isEmpty && profile.phoneNumber != null) {
          _phoneController.text = profile.phoneNumber!;
        }
      }
    });

    String? displayPictureUrl = profileState.uploadedProfilePictureUrl;

    if (displayPictureUrl == null || displayPictureUrl.isEmpty) {
      final filename = profileState.profile?.profilePicture;
      if (filename != null && filename.isNotEmpty) {
        displayPictureUrl = ApiEndpoints.profilePicture(filename);
      }
    }

    final bool isLoading = profileState.status == ProfileStatus.loading;

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
              onTap: isLoading
                  ? null
                  : _showProfileOptions,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: displayPictureUrl != null
                        ? NetworkImage(displayPictureUrl)
                        : null,
                    child: displayPictureUrl == null
                        ? const Icon(Icons.person, size: 60, color: Colors.grey)
                        : null,
                  ),

                  if (isLoading)
                    const SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),

                  if (!isLoading)
                    Positioned(
                      bottom: 0,
                      right: 0,
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
                onPressed: profileState.status == ProfileStatus.loading
                    ? null
                    : () async {
                        final currentProfile = profileState.profile;
                        if (currentProfile == null) {
                          SnackbarUtils.showWarning(
                              context, "No profile data available");
                          return;
                        }

                        final updatedProfile = AuthEntity(
                          authId: currentProfile.authId,
                          fullName: _fullNameController.text.trim(),
                          email: _emailController.text.trim(),
                          phoneNumber: _phoneController.text.trim().isEmpty
                              ? null
                              : _phoneController.text.trim(),
                          profilePicture: profileState.uploadedProfilePictureUrl ??
                              currentProfile.profilePicture,
                        );

                        await ref
                            .read(profileViewModelProvider.notifier)
                            .updateProfile(updatedProfile);

                        if (profileState.status == ProfileStatus.updated) {
                          SnackbarUtils.showSuccess(
                              context, "Profile updated successfully");
                        } else if (profileState.status == ProfileStatus.error &&
                            profileState.errorMessage != null) {
                          SnackbarUtils.showError(
                              context, profileState.errorMessage!);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: profileState.status == ProfileStatus.loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.black,
                        ),
                      )
                    : const Text(
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
