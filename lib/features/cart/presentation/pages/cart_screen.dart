import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/apps/theme/app_colors.dart';
import 'package:project_ease/core/api/api_endpoints.dart';
import 'package:project_ease/features/cart/domain/entities/cart_entity.dart';
import 'package:project_ease/features/cart/presentation/state/cart_state.dart';
import 'package:project_ease/features/cart/presentation/view_model/cart_view_model.dart';
import 'package:project_ease/features/order/presentation/pages/checkout_screen.dart';
import 'package:project_ease/features/store/presentation/view_model/store_view_model.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  Future<void> _onRefresh() async {
    await ref.read(cartViewModelProvider.notifier).loadCart();
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartViewModelProvider);
    final isTablet = MediaQuery.of(context).size.width >= 600;
    final storeState = ref.watch(storeViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'My Cart',
          style: TextStyle(
            fontSize: isTablet ? 20 : 17,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        actions: [
          if (!cartState.isEmpty)
            TextButton(
              onPressed: () => ref.read(cartViewModelProvider.notifier).clear(),
              child: Text(
                'Clear',
                style: TextStyle(
                  color: Colors.red.shade400,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: cartState.status == CartStatus.loading && cartState.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : cartState.isEmpty
          ? RefreshIndicator(
              onRefresh: _onRefresh,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: _EmptyCart(isTablet: isTablet),
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _onRefresh,
                    color: AppColors.primary,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(top: 8, bottom: 16),
                      itemCount: cartState.items.length,
                      itemBuilder: (_, i) => _CartItemTile(
                        item: cartState.items[i],
                        isTablet: isTablet,
                      ),
                    ),
                  ),
                ),
                _CartSummary(
                  cartState: cartState,
                  isTablet: isTablet,
                  onCheckout: storeState.selectedStore == null
                      ? null
                      : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CheckoutScreen(
                              storeId: storeState.selectedStore!.storeId,
                              storeName: storeState.selectedStore!.name,
                              items: cartState.items,
                              total: cartState.totalAmount,
                              isBuyNow: false,
                            ),
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  final bool isTablet;
  const _EmptyCart({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: isTablet ? 80 : 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Add products to get started',
            style: TextStyle(
              fontSize: isTablet ? 14 : 13,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItemTile extends ConsumerWidget {
  final CartItemEntity item;
  final bool isTablet;

  const _CartItemTile({required this.item, required this.isTablet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.read(cartViewModelProvider.notifier);
    final imageSize = isTablet ? 80.0 : 68.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.all(12),
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
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: imageSize,
              height: imageSize,
              child: item.product.productImage != null
                  ? Image.network(
                      '${ApiEndpoints.mediaServerUrl}${item.product.productImage}',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(imageSize),
                    )
                  : _placeholder(imageSize),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isTablet ? 15 : 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'NPR ${item.product.price.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _QtyButton(
                      icon: Icons.remove,
                      onTap: () => vm.updateQuantity(
                        item.cartItemId!,
                        item.quantity - 1,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${item.quantity}',
                      style: TextStyle(
                        fontSize: isTablet ? 15 : 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _QtyButton(
                      icon: Icons.add,
                      onTap: item.quantity < (item.product.stock ?? 99)
                          ? () => vm.updateQuantity(
                              item.cartItemId!,
                              item.quantity + 1,
                            )
                          : null,
                    ),
                    const Spacer(),
                    Text(
                      'NPR ${item.subtotal.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => vm.removeItem(item.cartItemId!),
            child: Icon(
              Icons.close_rounded,
              color: Colors.grey.shade400,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder(double size) => Container(
    color: Colors.grey.shade100,
    child: Icon(
      Icons.image_outlined,
      color: Colors.grey.shade300,
      size: size * 0.4,
    ),
  );
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _QtyButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.primary.withOpacity(0.1)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? AppColors.primary : Colors.grey.shade400,
        ),
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  final CartState cartState;
  final bool isTablet;
  final VoidCallback? onCheckout;

  const _CartSummary({
    required this.cartState,
    required this.isTablet,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(
        isTablet ? 32 : 20,
        16,
        isTablet ? 32 : 20,
        16 + bottomPad,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${cartState.totalItems} items',
                style: TextStyle(
                  fontSize: isTablet ? 15 : 14,
                  color: Colors.grey.shade500,
                ),
              ),
              Text(
                'NPR ${cartState.totalAmount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: isTablet ? 20 : 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: isTablet ? 54 : 50,
            child: ElevatedButton(
              onPressed: onCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade200,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Proceed to Checkout',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 15,
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
