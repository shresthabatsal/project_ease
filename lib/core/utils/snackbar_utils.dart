import 'package:flutter/material.dart';
import 'package:project_ease/apps/theme/app_colors.dart';

class SnackbarUtils {
  static void showError(BuildContext context, String message) {
    _show(
      context,
      message,
      accent: const Color(0xFFE53935),
      bg: const Color(0xFFFFF5F5),
      icon: Icons.error_outline_rounded,
    );
  }

  static void showSuccess(BuildContext context, String message) {
    _show(
      context,
      message,
      accent: const Color(0xFF2E7D32),
      bg: const Color(0xFFF1FFF3),
      icon: Icons.check_circle_outline_rounded,
    );
  }

  static void showInfo(BuildContext context, String message) {
    _show(
      context,
      message,
      accent: AppColors.primary,
      bg: const Color(0xFFFFFDE7),
      icon: Icons.info_outline_rounded,
    );
  }

  static void showWarning(BuildContext context, String message) {
    _show(
      context,
      message,
      accent: const Color(0xFFF57C00),
      bg: const Color(0xFFFFF8F0),
      icon: Icons.warning_amber_rounded,
    );
  }

  static void _show(
    BuildContext context,
    String message, {
    required Color accent,
    required Color bg,
    required IconData icon,
  }) {
    final isTablet = MediaQuery.of(context).size.width >= 600;
    final messenger = ScaffoldMessenger.of(context);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.symmetric(
            horizontal: isTablet ? 48 : 16,
            vertical: 12,
          ),
          padding: EdgeInsets.zero,
          duration: const Duration(seconds: 3),
          dismissDirection: DismissDirection.horizontal,
          content: GestureDetector(
            onTap: () => messenger.hideCurrentSnackBar(),
            child: Container(
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accent.withOpacity(0.25)),
                boxShadow: [
                  BoxShadow(
                    color: accent.withOpacity(0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Accent bar
                    Container(
                      width: 4,
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(16),
                        ),
                      ),
                    ),
                    // Icon
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      child: Icon(
                        icon,
                        color: accent,
                        size: isTablet ? 22 : 20,
                      ),
                    ),
                    // Message
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: 14,
                          bottom: 14,
                          right: isTablet ? 16 : 12,
                        ),
                        child: Text(
                          message,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: isTablet ? 15 : 13,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                    // Dismiss hint
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: Colors.black26,
                      ),
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
