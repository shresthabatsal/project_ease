import 'package:flutter/material.dart';
import 'package:project_ease/utils/app_fonts.dart';

class HomeActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const HomeActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    AppFonts.init(context);
    final bool isTablet = MediaQuery.of(context).size.width >= 600;

    return Card(
      color: Colors.grey.shade100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: isTablet ? 42 : 36,
              color: Colors.black,
            ),
            SizedBox(height: isTablet ? 12 : 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isTablet ? AppFonts.labelMedium : AppFonts.labelMedium,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}