import 'package:flutter/material.dart';
import 'package:project_ease/apps/theme/app_colors.dart';
import 'package:project_ease/core/utils/app_fonts.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.color,
    this.leadingIcon,
  });

  final VoidCallback onPressed;
  final String text;
  final Color? color;
  final IconData? leadingIcon;

  @override
  Widget build(BuildContext context) {
    AppFonts.init(context);
    final bool isTablet = MediaQuery.of(context).size.width >= 600;

    return SizedBox(
      width: double.infinity,
      height: isTablet ? 60 : 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppColors.primary,
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 24 : 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leadingIcon != null)
              Icon(
                leadingIcon,
                color: Colors.black,
                size: isTablet ? 28 : 20,
              ),
            if (leadingIcon != null) SizedBox(width: isTablet ? 12 : 8),
            Text(
              text,
              style: TextStyle(
                color: Colors.black,
                fontSize: isTablet ? AppFonts.bodyLarge : AppFonts.bodyMedium,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}