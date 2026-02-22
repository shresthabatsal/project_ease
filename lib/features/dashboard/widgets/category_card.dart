import 'package:flutter/material.dart';
import 'package:project_ease/apps/theme/app_colors.dart';
import 'package:project_ease/core/api/api_endpoints.dart';
import 'package:project_ease/features/product/domain/entities/category_entity.dart';

class CategoryCard extends StatelessWidget {
  final CategoryEntity category;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isTablet;

  const CategoryCard({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    final cardHeight = isTablet ? 100.0 : 80.0;
    final imageSize = isTablet ? 70.0 : 56.0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: cardHeight,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.06)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1,
          ),
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
            const SizedBox(width: 16),
            // Category name and description
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.primary : Colors.black87,
                    ),
                  ),
                  if (category.description != null &&
                      category.description!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      category.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isTablet ? 13 : 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Category image on the right
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
              child: SizedBox(
                width: imageSize + 10,
                height: cardHeight,
                child: category.image != null
                    ? Image.network(
                        '${ApiEndpoints.mediaServerUrl}${category.image}',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(imageSize),
                      )
                    : _placeholder(imageSize),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(double size) {
    return Container(
      color: AppColors.primary.withOpacity(0.08),
      child: Icon(
        Icons.category_outlined,
        color: AppColors.primary.withOpacity(0.4),
        size: size * 0.5,
      ),
    );
  }
}
