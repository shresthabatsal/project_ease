// ViewModel

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/features/cart/presentation/state/cart_state.dart';
import 'package:project_ease/features/order/data/repositories/order_repository.dart';
import 'package:project_ease/features/order/domain/repositories/order_repository.dart';
import 'package:project_ease/features/order/presentation/state/order_state.dart';

class OrderViewModel extends Notifier<OrderState> {
  late final IOrderRepository _repo;

  @override
  OrderState build() {
    _repo = ref.read(orderRepositoryProvider);
    return const OrderState();
  }

  // Create order from cart items
  Future<bool> createOrder({
    required String storeId,
    required String pickupDate,
    required String pickupTime,
    String? notes,
  }) async {
    state = state.copyWith(status: OrderStatus.loading);
    final result = await _repo.createOrder(
      storeId: storeId,
      pickupDate: pickupDate,
      pickupTime: pickupTime,
      notes: notes,
    );
    return result.fold(
      (failure) {
        state = state.copyWith(
          status: OrderStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (order) {
        // Clear cart on successful order
        ref.read(cartViewModelProvider.notifier).syncAfterOrder();
        state = state.copyWith(
          status: OrderStatus.success,
          currentOrder: order,
        );
        return true;
      },
    );
  }

  // Direct buy now flow
  Future<bool> buyNow({
    required String productId,
    required int quantity,
    required String storeId,
    required String pickupDate,
    required String pickupTime,
    String? notes,
  }) async {
    state = state.copyWith(status: OrderStatus.loading);
    final result = await _repo.buyNow(
      productId: productId,
      quantity: quantity,
      storeId: storeId,
      pickupDate: pickupDate,
      pickupTime: pickupTime,
      notes: notes,
    );
    return result.fold(
      (failure) {
        state = state.copyWith(
          status: OrderStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (order) {
        state = state.copyWith(
          status: OrderStatus.success,
          currentOrder: order,
        );
        return true;
      },
    );
  }

  Future<void> loadOrders() async {
    state = state.copyWith(status: OrderStatus.loading);
    final result = await _repo.getUserOrders();
    result.fold(
      (f) => state = state.copyWith(
        status: OrderStatus.error,
        errorMessage: f.message,
      ),
      (orders) =>
          state = state.copyWith(status: OrderStatus.success, orders: orders),
    );
  }

  Future<bool> submitReceipt({
    required String orderId,
    required String receiptImagePath,
    String? paymentMethod,
    String? notes,
  }) async {
    state = state.copyWith(status: OrderStatus.loading);
    final result = await _repo.submitReceipt(
      orderId: orderId,
      receiptImagePath: receiptImagePath,
      paymentMethod: paymentMethod,
      notes: notes,
    );
    return result.fold(
      (f) {
        state = state.copyWith(
          status: OrderStatus.error,
          errorMessage: f.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(status: OrderStatus.success);
        return true;
      },
    );
  }

  void reset() => state = const OrderState();
}
