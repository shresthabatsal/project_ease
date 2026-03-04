import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/apps/theme/app_colors.dart';
import 'package:project_ease/core/api/api_endpoints.dart';
import 'package:project_ease/features/cart/domain/entities/cart_entity.dart';
import 'package:project_ease/features/cart/presentation/state/cart_state.dart';
import 'package:project_ease/features/dashboard/presentation/checkout_screen.dart';
import 'package:project_ease/features/product/domain/entities/product_entity.dart';
import 'package:project_ease/features/rating/presentation/widgets/rating_section.dart';
import 'package:project_ease/core/utils/snackbar_utils.dart';
import 'package:project_ease/features/store/presentation/view_model/store_view_model.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final ProductEntity product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _quantity = 1;

  int get _maxQty => widget.product.stock ?? 99;
  bool get _isOutOfStock =>
      widget.product.stock != null && widget.product.stock! <= 0;
  bool get _isLowStock =>
      widget.product.stock != null &&
      widget.product.stock! > 0 &&
      widget.product.stock! <= 5;

  void _increment() {
    if (_quantity < _maxQty) {
      HapticFeedback.lightImpact();
      setState(() => _quantity++);
    }
  }

  void _decrement() {
    if (_quantity > 1) {
      HapticFeedback.lightImpact();
      setState(() => _quantity--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;
    final screenWidth = MediaQuery.of(context).size.width;
    final imageHeight = isTablet ? screenWidth * 0.45 : screenWidth * 0.75;
    final totalPrice = widget.product.price * _quantity;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Scrollable content
          CustomScrollView(
            slivers: [
              // Image with back button overlay
              SliverAppBar(
                expandedHeight: imageHeight,
                pinned: true,
                backgroundColor: Colors.white,
                elevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: _ProductImage(
                    imageUrl: widget.product.productImage != null
                        ? '${ApiEndpoints.mediaServerUrl}${widget.product.productImage}'
                        : null,
                    height: imageHeight,
                  ),
                ),
              ),

              // Product info
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    isTablet ? 32 : 20,
                    20,
                    isTablet ? 32 : 20,
                    120 + MediaQuery.of(context).padding.bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.product.categoryName != null ||
                          widget.product.subcategoryName != null)
                        Wrap(
                          spacing: 6,
                          children: [
                            if (widget.product.categoryName != null)
                              _Badge(label: widget.product.categoryName!),
                            if (widget.product.subcategoryName != null)
                              _Badge(
                                label: widget.product.subcategoryName!,
                                outlined: true,
                              ),
                          ],
                        ),

                      const SizedBox(height: 10),

                      // Name
                      Text(
                        widget.product.name,
                        style: TextStyle(
                          fontSize: isTablet ? 26 : 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                          height: 1.25,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Price and stock row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'NPR ${widget.product.price.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: isTablet ? 26 : 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          const Spacer(),
                          if (_isOutOfStock)
                            _StockBadge(
                              label: 'Out of stock',
                              color: Colors.red.shade400,
                            )
                          else if (_isLowStock)
                            _StockBadge(
                              label: 'Only ${widget.product.stock} left',
                              color: Colors.orange.shade600,
                            )
                          else if (widget.product.stock != null)
                            _StockBadge(
                              label: 'In stock',
                              color: Colors.green.shade600,
                            ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      const SizedBox(height: 20),

                      // Description
                      if (widget.product.description != null &&
                          widget.product.description!.isNotEmpty) ...[
                        Text(
                          'Description',
                          style: TextStyle(
                            fontSize: isTablet ? 15 : 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.black54,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.product.description!,
                          style: TextStyle(
                            fontSize: isTablet ? 15 : 14,
                            color: Colors.black54,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Divider(height: 1, color: Color(0xFFEEEEEE)),
                        const SizedBox(height: 20),
                      ],

                      // Store name
                      if (widget.product.storeName != null)
                        Row(
                          children: [
                            Icon(
                              Icons.store_outlined,
                              size: 16,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.product.storeName!,
                              style: TextStyle(
                                fontSize: isTablet ? 14 : 13,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 24),

                      // Quantity selector
                      Row(
                        children: [
                          Text(
                            'Quantity',
                            style: TextStyle(
                              fontSize: isTablet ? 16 : 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const Spacer(),
                          _QuantitySelector(
                            quantity: _quantity,
                            max: _maxQty,
                            disabled: _isOutOfStock,
                            onDecrement: _decrement,
                            onIncrement: _increment,
                            isTablet: isTablet,
                          ),
                        ],
                      ),

                      if (_quantity > 1) ...[
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Total: NPR \${totalPrice.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: isTablet ? 14 : 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      RatingSection(
                        productId: widget.product.productId,
                        isTablet: isTablet,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Fixed bottom action bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _BottomActionBar(
              isOutOfStock: _isOutOfStock,
              isTablet: isTablet,
              onAddToCart: () async {
                final added = await ref
                    .read(cartViewModelProvider.notifier)
                    .addItem(widget.product, _quantity);
                if (!mounted) return;
                if (added) {
                  SnackbarUtils.showSuccess(
                    context,
                    '${widget.product.name} ×$_quantity added to cart',
                  );
                } else {
                  SnackbarUtils.showError(
                    context,
                    'Failed to add to cart. Please try again.',
                  );
                }
              },
              onBuyNow: () {
                final storeState = ref.read(storeViewModelProvider);
                if (storeState.selectedStore == null) {
                  SnackbarUtils.showWarning(
                    context,
                    'Please select a store first.',
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CheckoutScreen(
                      storeId: storeState.selectedStore!.storeId,
                      storeName: storeState.selectedStore!.name,
                      items: [
                        CartItemEntity(
                          product: widget.product,
                          quantity: _quantity,
                        ),
                      ],
                      total: widget.product.price * _quantity,
                      isBuyNow: true,
                      buyNowProduct: widget.product,
                      buyNowQuantity: _quantity,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Product Image

class _ProductImage extends StatelessWidget {
  final String? imageUrl;
  final double height;

  const _ProductImage({this.imageUrl, required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: imageUrl != null
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholder(),
            )
          : _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey.shade100,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: Colors.grey.shade300,
          size: 64,
        ),
      ),
    );
  }
}

// Badge

class _Badge extends StatelessWidget {
  final String label;
  final bool outlined;

  const _Badge({required this.label, this.outlined = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: outlined
            ? Colors.transparent
            : AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: outlined
              ? AppColors.primary.withOpacity(0.3)
              : Colors.transparent,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

// Stock Badge

class _StockBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StockBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// Quantity Selector

class _QuantitySelector extends StatelessWidget {
  final int quantity;
  final int max;
  final bool disabled;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final bool isTablet;

  const _QuantitySelector({
    required this.quantity,
    required this.max,
    required this.disabled,
    required this.onDecrement,
    required this.onIncrement,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final btnSize = isTablet ? 38.0 : 34.0;
    final fontSize = isTablet ? 18.0 : 16.0;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _QtyButton(
            icon: Icons.remove,
            size: btnSize,
            enabled: !disabled && quantity > 1,
            onTap: onDecrement,
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: SizedBox(
              key: ValueKey(quantity),
              width: isTablet ? 44 : 38,
              child: Text(
                '$quantity',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: disabled ? Colors.grey : Colors.black87,
                ),
              ),
            ),
          ),
          _QtyButton(
            icon: Icons.add,
            size: btnSize,
            enabled: !disabled && quantity < max,
            onTap: onIncrement,
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final bool enabled;
  final VoidCallback onTap;

  const _QtyButton({
    required this.icon,
    required this.size,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: enabled ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? Colors.white : Colors.grey.shade400,
        ),
      ),
    );
  }
}

// Bottom Action Bar

class _BottomActionBar extends StatelessWidget {
  final bool isOutOfStock;
  final bool isTablet;
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;

  const _BottomActionBar({
    required this.isOutOfStock,
    required this.isTablet,
    required this.onAddToCart,
    required this.onBuyNow,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
        isTablet ? 32 : 20,
        14,
        isTablet ? 32 : 20,
        14 + bottomPad,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Add to Cart
          Expanded(
            child: OutlinedButton(
              onPressed: isOutOfStock ? null : onAddToCart,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(
                  color: isOutOfStock
                      ? Colors.grey.shade300
                      : AppColors.primary,
                ),
                padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: isTablet ? 20 : 18),
                  const SizedBox(width: 6),
                  Text(
                    'Add to Cart',
                    style: TextStyle(
                      fontSize: isTablet ? 15 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Buy Now
          Expanded(
            child: ElevatedButton(
              onPressed: isOutOfStock ? null : onBuyNow,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade200,
                padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                isOutOfStock ? 'Out of Stock' : 'Buy Now',
                style: TextStyle(
                  fontSize: isTablet ? 15 : 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
