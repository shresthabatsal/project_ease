import 'package:flutter/material.dart';
import 'package:project_ease/utils/app_fonts.dart';

class ProductCard extends StatelessWidget {
  final String imagePath;
  final String name;
  final String price;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.imagePath,
    required this.name,
    required this.price,
    this.isFavorite = false,
    required this.onFavoriteTap,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    AppFonts.init(context);
    final bool isTablet = MediaQuery.of(context).size.width >= 600;

    return Card(
      color: Colors.grey.shade100,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Part
            Stack(
              children: [
                SizedBox(
                  height: isTablet ? 220 : 180,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: Image.asset(
                      imagePath,
                      
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Positioned(
                //   top: isTablet ? 12 : 8,
                //   right: isTablet ? 12 : 8,
                //   child: InkWell(
                //     borderRadius: BorderRadius.circular(20),
                //     onTap: onFavoriteTap,
                //     child: Container(
                //       padding: EdgeInsets.all(isTablet ? 8 : 6),
                //       decoration: BoxDecoration(
                //         color: Colors.white,
                //         shape: BoxShape.circle,
                //       ),
                //       child: Icon(
                //         isFavorite ? Icons.favorite : Icons.favorite_border,
                //         color: isFavorite ? Colors.red : Colors.grey,
                //         size: isTablet ? 24 : 20,
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),

            // Bottom Part
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 12 : 8,
                vertical: isTablet ? 12 : 8,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: isTablet ? AppFonts.bodyLarge : AppFonts.bodyMedium,
                    ),
                  ),
                  SizedBox(height: isTablet ? 6 : 4),
                  Text(
                    price,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                      fontSize: isTablet ? AppFonts.bodyMedium : AppFonts.labelMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}