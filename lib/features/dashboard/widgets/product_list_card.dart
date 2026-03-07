import 'package:flutter/material.dart';
import 'package:project_ease/apps/theme/app_colors.dart';
import 'package:project_ease/core/api/api_endpoints.dart';
import 'package:project_ease/features/product/presentation/pages/product_detail_screen.dart';
import 'package:project_ease/features/product/domain/entities/product_entity.dart';

class ProductListCard extends StatelessWidget {
  final ProductEntity product;
  final bool isTablet;

  const ProductListCard({
    super.key,
    required this.product,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    final imageSize = isTablet ? 110.0 : 90.0;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(product: product),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: imageSize,
                height: imageSize,
                child: product.productImage != null
                    ? Image.network(
                        '${ApiEndpoints.mediaServerUrl}${product.productImage}',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _imagePlaceholder(imageSize),
                      )
                    : _imagePlaceholder(imageSize),
              ),
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  if (product.description != null &&
                      product.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      product.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isTablet ? 13 : 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'NPR ${product.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      if (product.categoryName != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            product.categoryName!,
                            style: TextStyle(
                              fontSize: isTablet ? 11 : 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (product.stock != null && product.stock! <= 5) ...[
                    const SizedBox(height: 4),
                    Text(
                      product.stock! <= 0
                          ? 'Out of stock'
                          : 'Only ${product.stock} left!',
                      style: TextStyle(
                        fontSize: isTablet ? 12 : 10,
                        color: product.stock! <= 0
                            ? Colors.red.shade600
                            : Colors.red.shade400,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Chevron
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.shade300,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder(double size) {
    return Container(
      color: Colors.grey.shade100,
      child: Icon(
        Icons.image_outlined,
        color: Colors.grey.shade300,
        size: size * 0.45,
      ),
    );
  }
}
