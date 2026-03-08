import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_ease/apps/theme/app_colors.dart';
import 'package:project_ease/core/api/api_endpoints.dart';
import 'package:project_ease/core/utils/snackbar_utils.dart';
import 'package:project_ease/features/auth/presentation/pages/login_screen.dart';
import 'package:project_ease/features/auth/domain/entities/auth_entity.dart';
import 'package:project_ease/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:project_ease/features/order/presentation/pages/my_orders_screen.dart';
import 'package:project_ease/features/profile/presentation/view_model/profile_view_model.dart';
import 'package:project_ease/features/support/presentation/pages/my_tickets_screen.dart';
import 'package:project_ease/core/services/storage/app_settings.dart';
import 'package:project_ease/features/profile/presentation/state/profile_state.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileViewModelProvider);
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Profile',
          style: TextStyle(
            fontSize: isTablet ? 20 : 17,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ),
      body: switch (state.status) {
        ProfileStatus.initial || ProfileStatus.loading => const Center(
          child: CircularProgressIndicator(),
        ),
        ProfileStatus.error => _ErrorView(
          message: state.errorMessage ?? 'Failed to load profile.',
          onRetry: () =>
              ref.read(profileViewModelProvider.notifier).loadProfile(),
        ),
        _ => _ProfileBody(user: state.user!, isTablet: isTablet),
      },
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  final AuthEntity user;
  final bool isTablet;

  const _ProfileBody({required this.user, required this.isTablet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 48 : 20,
        vertical: 24,
      ),
      child: Column(
        children: [
          // ── Avatar ──────────────────────────────────────────────────
          GestureDetector(
            onTap: () => _showAvatarSheet(context, user.profilePicture),
            child: Stack(
              children: [
                _Avatar(url: user.profilePicture, size: isTablet ? 110 : 90),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.black87,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          Text(
            user.fullName,
            style: TextStyle(
              fontSize: isTablet ? 22 : 20,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            user.email,
            style: TextStyle(fontSize: isTablet ? 14 : 13, color: Colors.grey),
          ),

          const SizedBox(height: 32),

          // Account info rows
          _InfoCard(
            isTablet: isTablet,
            rows: [
              _EditableRow(
                icon: Icons.person_outline_rounded,
                label: 'Full Name',
                value: user.fullName,
                isTablet: isTablet,
                onTap: () => _showSingleFieldSheet(
                  context,
                  title: 'Change Name',
                  label: 'Full Name',
                  icon: Icons.person_outline_rounded,
                  initialValue: user.fullName,
                  keyboardType: TextInputType.name,
                  onSave: (val) => ref
                      .read(profileViewModelProvider.notifier)
                      .updateProfile(fullName: val),
                ),
              ),
              _EditableRow(
                icon: Icons.email_outlined,
                label: 'Email',
                value: user.email,
                isTablet: isTablet,
                onTap: () => _showEmailSheet(context, user.email),
              ),
              _EditableRow(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: user.phoneNumber?.isNotEmpty == true
                    ? user.phoneNumber!
                    : 'Not set',
                isTablet: isTablet,
                valueColor: user.phoneNumber?.isNotEmpty == true
                    ? null
                    : Colors.grey.shade400,
                onTap: () => _showSingleFieldSheet(
                  context,
                  title: 'Change Phone',
                  label: 'Phone Number',
                  icon: Icons.phone_outlined,
                  initialValue: user.phoneNumber ?? '',
                  keyboardType: TextInputType.phone,
                  onSave: (val) => ref
                      .read(profileViewModelProvider.notifier)
                      .updateProfile(phoneNumber: val),
                ),
              ),
              _EditableRow(
                icon: Icons.lock_outline_rounded,
                label: 'Password',
                value: '••••••••',
                isTablet: isTablet,
                onTap: () => _showPasswordSheet(context),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // My Orders
          _ActionRow(
            icon: Icons.receipt_long_outlined,
            label: 'My Orders',
            isTablet: isTablet,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
            ),
          ),

          const SizedBox(height: 12),

          // App Preferences
          _SectionCard(
            isTablet: isTablet,
            children: [_ShakeToggleRow(isTablet: isTablet)],
          ),

          const SizedBox(height: 28),

          // Support
          SizedBox(
            width: double.infinity,
            height: isTablet ? 52 : 48,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyTicketsScreen()),
              ),
              icon: const Icon(Icons.support_agent_rounded, size: 18),
              label: const Text('Raise a Ticket'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary.withOpacity(0.08),
                foregroundColor: AppColors.primary,
                elevation: 0,
                side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Logout button
          SizedBox(
            width: double.infinity,
            height: isTablet ? 52 : 48,
            child: ElevatedButton.icon(
              onPressed: () => _showLogoutDialog(context, ref),
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('Log Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red.shade600,
                elevation: 0,
                side: BorderSide(color: Colors.red.shade200),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // Sheet launchers

  void _showAvatarSheet(BuildContext context, String? currentUrl) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) =>
          _AvatarOptionsSheet(currentUrl: currentUrl, isTablet: isTablet),
    );
  }

  void _showSingleFieldSheet(
    BuildContext context, {
    required String title,
    required String label,
    required IconData icon,
    required String initialValue,
    required TextInputType keyboardType,
    required Future<bool> Function(String) onSave,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SingleFieldSheet(
        title: title,
        label: label,
        icon: icon,
        initialValue: initialValue,
        keyboardType: keyboardType,
        onSave: onSave,
        isTablet: isTablet,
      ),
    );
  }

  void _showEmailSheet(BuildContext context, String currentEmail) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _EmailSheet(currentEmail: currentEmail, isTablet: isTablet),
    );
  }

  void _showPasswordSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PasswordSheet(isTablet: isTablet),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Log out?',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        content: const Text(
          'Are you sure you want to log out of your account?',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Log out',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(authViewModelProvider.notifier).logout();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }
}

// My Orders
class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isTablet;
  final VoidCallback onTap;

  const _ActionRow({
    required this.icon,
    required this.label,
    required this.isTablet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 17, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: isTablet ? 15 : 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: Colors.grey.shade300,
            ),
          ],
        ),
      ),
    );
  }
}

// Info  Card
class _InfoCard extends StatelessWidget {
  final List<_EditableRow> rows;
  final bool isTablet;

  const _InfoCard({required this.rows, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i < rows.length - 1)
              const Divider(
                height: 1,
                indent: 56,
                color: const Color(0xFFF0F0F0),
              ),
          ],
        ],
      ),
    );
  }
}

class _EditableRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isTablet;
  final Color? valueColor;
  final VoidCallback onTap;

  const _EditableRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isTablet,
    required this.onTap,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 17, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: isTablet ? 15 : 14,
                      fontWeight: FontWeight.w600,
                      color: valueColor ?? Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: Colors.grey.shade300,
            ),
          ],
        ),
      ),
    );
  }
}

// Avatar

class _Avatar extends StatelessWidget {
  final String? url;
  final double size;
  final File? localFile;

  // ignore: unused_element_parameter
  const _Avatar({this.url, required this.size, this.localFile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: localFile != null
            ? Image.file(localFile!, fit: BoxFit.cover)
            : url != null
            ? Image.network(
                '${ApiEndpoints.mediaServerUrl}$url',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() =>
      Icon(Icons.person_rounded, size: size * 0.5, color: Colors.grey.shade300);
}

class _SheetWrapper extends StatelessWidget {
  final String title;
  final bool isTablet;
  final List<Widget> children;

  const _SheetWrapper({
    required this.title,
    required this.isTablet,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        isTablet ? 32 : 20,
        0,
        isTablet ? 32 : 20,
        bottomPad,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            ...children,
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _AvatarOptionsSheet extends ConsumerWidget {
  final String? currentUrl;
  final bool isTablet;

  const _AvatarOptionsSheet({required this.currentUrl, required this.isTablet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> pick(ImageSource source) async {
      Navigator.pop(context);
      final file = await ImagePicker().pickImage(
        source: source,
        imageQuality: 85,
      );
      if (file == null || !context.mounted) return;
      final success = await ref
          .read(profileViewModelProvider.notifier)
          .updateProfile(profilePicturePath: file.path);
      if (!context.mounted) return;
      if (success) {
        SnackbarUtils.showSuccess(context, 'Profile picture updated.');
      } else {
        SnackbarUtils.showError(
          context,
          ref.read(profileViewModelProvider).errorMessage ??
              'Failed to update picture.',
        );
      }
    }

    Future<void> remove() async {
      Navigator.pop(context);
      final success = await ref
          .read(profileViewModelProvider.notifier)
          .updateProfile(removeProfilePicture: true);
      if (!context.mounted) return;
      if (success) {
        SnackbarUtils.showSuccess(context, 'Profile picture removed.');
      } else {
        SnackbarUtils.showError(
          context,
          ref.read(profileViewModelProvider).errorMessage ?? 'Failed.',
        );
      }
    }

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Profile Picture',
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          _OptionTile(
            icon: Icons.camera_alt_outlined,
            label: 'Take a photo',
            onTap: () => pick(ImageSource.camera),
          ),
          _OptionTile(
            icon: Icons.photo_library_outlined,
            label: 'Choose from gallery',
            onTap: () => pick(ImageSource.gallery),
          ),
          if (currentUrl != null)
            _OptionTile(
              icon: Icons.delete_outline_rounded,
              label: 'Remove photo',
              iconColor: Colors.red.shade400,
              labelColor: Colors.red.shade400,
              onTap: remove,
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? labelColor;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.primary).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: iconColor ?? AppColors.primary),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: labelColor ?? Colors.black87,
        ),
      ),
      onTap: onTap,
    );
  }
}

// Single field sheet

class _SingleFieldSheet extends ConsumerStatefulWidget {
  final String title;
  final String label;
  final IconData icon;
  final String initialValue;
  final TextInputType keyboardType;
  final Future<bool> Function(String) onSave;
  final bool isTablet;

  const _SingleFieldSheet({
    required this.title,
    required this.label,
    required this.icon,
    required this.initialValue,
    required this.keyboardType,
    required this.onSave,
    required this.isTablet,
  });

  @override
  ConsumerState<_SingleFieldSheet> createState() => _SingleFieldSheetState();
}

class _SingleFieldSheetState extends ConsumerState<_SingleFieldSheet> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final val = _ctrl.text.trim();
    if (val.isEmpty) {
      SnackbarUtils.showError(context, '${widget.label} cannot be empty.');
      return;
    }
    if (val == widget.initialValue) {
      Navigator.pop(context);
      return;
    }
    final success = await widget.onSave(val);
    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
      SnackbarUtils.showSuccess(context, '${widget.label} updated.');
    } else {
      final error = ref.read(profileViewModelProvider).errorMessage;
      SnackbarUtils.showError(
        context,
        error ?? 'Failed to update ${widget.label}.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUpdating =
        ref.watch(profileViewModelProvider).status == ProfileStatus.updating;

    return _SheetWrapper(
      title: widget.title,
      isTablet: widget.isTablet,
      children: [
        _FieldInput(
          controller: _ctrl,
          label: widget.label,
          icon: widget.icon,
          keyboardType: widget.keyboardType,
          isTablet: widget.isTablet,
        ),
        const SizedBox(height: 20),
        _SaveButton(
          label: 'Save',
          loading: isUpdating,
          onTap: _save,
          isTablet: widget.isTablet,
        ),
      ],
    );
  }
}

// Email sheet

class _EmailSheet extends ConsumerStatefulWidget {
  final String currentEmail;
  final bool isTablet;

  const _EmailSheet({required this.currentEmail, required this.isTablet});

  @override
  ConsumerState<_EmailSheet> createState() => _EmailSheetState();
}

class _EmailSheetState extends ConsumerState<_EmailSheet> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.currentEmail);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final email = _ctrl.text.trim();
    if (email.isEmpty) {
      SnackbarUtils.showError(context, 'Email cannot be empty.');
      return;
    }
    if (!RegExp(r'^[\w\-.]+@[\w\-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
      SnackbarUtils.showError(context, 'Enter a valid email address.');
      return;
    }
    if (email == widget.currentEmail) {
      Navigator.pop(context);
      return;
    }
    final success = await ref
        .read(profileViewModelProvider.notifier)
        .updateProfile(email: email);
    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
      SnackbarUtils.showSuccess(context, 'Email updated.');
    } else {
      final error = ref.read(profileViewModelProvider).errorMessage;
      SnackbarUtils.showError(context, error ?? 'Failed to update email.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUpdating =
        ref.watch(profileViewModelProvider).status == ProfileStatus.updating;

    return _SheetWrapper(
      title: 'Change Email',
      isTablet: widget.isTablet,
      children: [
        _FieldInput(
          controller: _ctrl,
          label: 'Email Address',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          isTablet: widget.isTablet,
        ),
        const SizedBox(height: 20),
        _SaveButton(
          label: 'Update Email',
          loading: isUpdating,
          onTap: _save,
          isTablet: widget.isTablet,
        ),
      ],
    );
  }
}

// Password sheet

class _PasswordSheet extends ConsumerStatefulWidget {
  final bool isTablet;

  const _PasswordSheet({required this.isTablet});

  @override
  ConsumerState<_PasswordSheet> createState() => _PasswordSheetState();
}

class _PasswordSheetState extends ConsumerState<_PasswordSheet> {
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final newPass = _newCtrl.text;
    final confirm = _confirmCtrl.text;

    if (newPass.length < 6) {
      SnackbarUtils.showError(
        context,
        'Password must be at least 6 characters.',
      );
      return;
    }
    if (newPass != confirm) {
      SnackbarUtils.showError(context, 'Passwords do not match.');
      return;
    }

    final success = await ref
        .read(profileViewModelProvider.notifier)
        .updateProfile(password: newPass);
    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
      SnackbarUtils.showSuccess(context, 'Password updated.');
    } else {
      final error = ref.read(profileViewModelProvider).errorMessage;
      SnackbarUtils.showError(context, error ?? 'Failed to update password.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUpdating =
        ref.watch(profileViewModelProvider).status == ProfileStatus.updating;

    return _SheetWrapper(
      title: 'Change Password',
      isTablet: widget.isTablet,
      children: [
        _FieldInput(
          controller: _newCtrl,
          label: 'New Password',
          icon: Icons.lock_outline_rounded,
          isTablet: widget.isTablet,
          obscureText: _obscureNew,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureNew
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 18,
              color: Colors.grey.shade400,
            ),
            onPressed: () => setState(() => _obscureNew = !_obscureNew),
          ),
        ),
        const SizedBox(height: 12),
        _FieldInput(
          controller: _confirmCtrl,
          label: 'Confirm Password',
          icon: Icons.lock_outline_rounded,
          isTablet: widget.isTablet,
          obscureText: _obscureConfirm,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirm
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 18,
              color: Colors.grey.shade400,
            ),
            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
          ),
        ),
        const SizedBox(height: 20),
        _SaveButton(
          label: 'Update Password',
          loading: isUpdating,
          onTap: _save,
          isTablet: widget.isTablet,
        ),
      ],
    );
  }
}

class _FieldInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isTablet;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;

  const _FieldInput({
    required this.controller,
    required this.label,
    required this.icon,
    required this.isTablet,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: TextStyle(fontSize: isTablet ? 15 : 14, color: Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontSize: isTablet ? 13 : 12,
            color: Colors.grey.shade500,
          ),
          prefixIcon: Icon(icon, size: 18, color: AppColors.primary),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback onTap;
  final bool isTablet;

  const _SaveButton({
    required this.label,
    required this.loading,
    required this.onTap,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: isTablet ? 52 : 48,
      child: ElevatedButton(
        onPressed: loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade200,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: TextStyle(
                  fontSize: isTablet ? 16 : 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}

// Error View

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 16),
          TextButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  final bool isTablet;

  const _SectionCard({required this.children, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

// ShakeToggleRow
class _ShakeToggleRow extends ConsumerWidget {
  final bool isTablet;
  const _ShakeToggleRow({required this.isTablet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(
      appSettingsProvider.select((s) => s.shakeEnabled),
    );

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 20 : 16,
        vertical: 4,
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.vibration_rounded,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shake to View Orders',
                  style: TextStyle(
                    fontSize: isTablet ? 15 : 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Shake your phone to quickly open orders',
                  style: TextStyle(
                    fontSize: isTablet ? 13 : 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: enabled,
            onChanged: (val) =>
                ref.read(appSettingsProvider.notifier).setShakeEnabled(val),
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
