import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/features/cart/domain/entities/cart_entity.dart';
import 'package:project_ease/features/cart/domain/usecases/add_to_cart_usecase.dart';
import 'package:project_ease/features/cart/domain/usecases/clear_cart_usecase.dart';
import 'package:project_ease/features/cart/domain/usecases/get_cart_usecase.dart';
import 'package:project_ease/features/cart/domain/usecases/remove_cart_item_usecase.dart';
import 'package:project_ease/features/cart/domain/usecases/update_cart_usecase.dart';
import 'package:project_ease/features/cart/presentation/state/cart_state.dart';
import 'package:project_ease/features/product/domain/entities/product_entity.dart';

final cartViewModelProvider = NotifierProvider<CartViewModel, CartState>(
  () => CartViewModel(),
);

class CartViewModel extends Notifier<CartState> {
  late final GetCartUsecase _getCart;
  late final AddToCartUsecase _addToCart;
  late final UpdateCartItemUsecase _updateCartItem;
  late final RemoveCartItemUsecase _removeCartItem;
  late final ClearCartUsecase _clearCart;

  @override
  CartState build() {
    _getCart = ref.read(getCartUsecaseProvider);
    _addToCart = ref.read(addToCartUsecaseProvider);
    _updateCartItem = ref.read(updateCartItemUsecaseProvider);
    _removeCartItem = ref.read(removeCartItemUsecaseProvider);
    _clearCart = ref.read(clearCartUsecaseProvider);
    Future.microtask(loadCart);
    return const CartState();
  }

  Future<void> loadCart() async {
    state = state.copyWith(status: CartStatus.loading);
    final result = await _getCart();
    result.fold(
      (f) => state = state.copyWith(
        status: CartStatus.error,
        errorMessage: f.message,
      ),
      (items) =>
          state = state.copyWith(status: CartStatus.loaded, items: items),
    );
  }

  // Add
  Future<bool> addItem(ProductEntity product, int quantity) async {
    final before = state.items;
    _optimisticAdd(product, quantity);

    final result = await _addToCart(
      AddToCartParams(productId: product.productId, quantity: quantity),
    );
    return result.fold(
      (f) {
        state = state.copyWith(items: before);
        return false;
      },
      (_) {
        loadCart();
        return true;
      },
    );
  }

  void _optimisticAdd(ProductEntity product, int quantity) {
    final items = List<CartItemEntity>.from(state.items);
    final idx = items.indexWhere(
      (i) => i.product.productId == product.productId,
    );
    if (idx >= 0) {
      final existing = items[idx];
      final maxQty = product.stock ?? 99;
      final newQty = (existing.quantity + quantity).clamp(1, maxQty);
      items[idx] = existing.copyWith(quantity: newQty);
    } else {
      items.add(
        CartItemEntity(
          cartItemId: 'temp_${product.productId}',
          product: product,
          quantity: quantity,
        ),
      );
    }
    state = state.copyWith(items: items);
  }

  // Update quantity
  Future<void> updateQuantity(String cartItemId, int quantity) async {
    if (quantity <= 0) {
      await removeItem(cartItemId);
      return;
    }
    final before = state.items;
    state = state.copyWith(
      items: state.items.map((i) {
        if (i.cartItemId == cartItemId) return i.copyWith(quantity: quantity);
        return i;
      }).toList(),
    );
    final result = await _updateCartItem(
      UpdateCartItemParams(cartItemId: cartItemId, quantity: quantity),
    );
    result.fold((f) => state = state.copyWith(items: before), (updated) {
      state = state.copyWith(
        items: state.items.map((i) {
          if (i.cartItemId == cartItemId) return updated;
          return i;
        }).toList(),
      );
    });
  }

  // Remove
  Future<void> removeItem(String cartItemId) async {
    final before = state.items;
    state = state.copyWith(
      items: state.items.where((i) => i.cartItemId != cartItemId).toList(),
    );
    final result = await _removeCartItem(cartItemId);
    result.fold((f) => state = state.copyWith(items: before), (_) {});
  }

  // Clear
  Future<void> clear() async {
    final before = state.items;
    state = state.copyWith(items: []);
    final result = await _clearCart();
    result.fold((f) => state = state.copyWith(items: before), (_) {});
  }

  // Sync after order
  Future<void> syncAfterOrder() => loadCart();
}
