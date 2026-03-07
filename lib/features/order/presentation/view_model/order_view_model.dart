import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/features/cart/presentation/view_model/cart_view_model.dart';
import 'package:project_ease/features/order/data/repositories/order_repository.dart';
import 'package:project_ease/features/order/domain/entities/order_entity.dart';
import 'package:project_ease/features/order/domain/repositories/order_repository.dart';
import 'package:project_ease/features/order/presentation/state/order_state.dart';

final orderViewModelProvider = NotifierProvider<OrderViewModel, OrderState>(
  () => OrderViewModel(),
);

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

  // Fetch a single order by ID
  Future<OrderEntity?> fetchOrder(String orderId) async {
    final result = await _repo.getOrder(orderId);
    return result.fold(
      (f) {
        state = state.copyWith(
          status: OrderStatus.error,
          errorMessage: f.message,
        );
        return null;
      },
      (order) {
        state = state.copyWith(status: OrderStatus.success);
        return order;
      },
    );
  }

  // Cancel order
  Future<bool> cancelOrder(String orderId, String? reason) async {
    state = state.copyWith(status: OrderStatus.loading);
    final result = await _repo.cancelOrder(orderId, reason);
    return result.fold(
      (f) {
        state = state.copyWith(
          status: OrderStatus.error,
          errorMessage: f.message,
        );
        return false;
      },
      (order) {
        // Refresh the list
        final updated = state.orders
            .map((o) => o.orderId == orderId ? order : o)
            .toList();
        state = state.copyWith(status: OrderStatus.success, orders: updated);
        return true;
      },
    );
  }

  void reset() => state = const OrderState();
}
