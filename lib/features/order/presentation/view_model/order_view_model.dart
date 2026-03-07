import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/features/cart/presentation/view_model/cart_view_model.dart';
import 'package:project_ease/features/order/domain/entities/order_entity.dart';
import 'package:project_ease/features/order/domain/usecases/buy_now_usecase.dart';
import 'package:project_ease/features/order/domain/usecases/cancel_order_usecase.dart';
import 'package:project_ease/features/order/domain/usecases/create_order_usecase.dart';
import 'package:project_ease/features/order/domain/usecases/get_orders_usecasse.dart';
import 'package:project_ease/features/order/domain/usecases/get_users_order_usecase.dart';
import 'package:project_ease/features/order/domain/usecases/submit_receipt_usecase.dart';
import 'package:project_ease/features/order/presentation/state/order_state.dart';

final orderViewModelProvider = NotifierProvider<OrderViewModel, OrderState>(
  () => OrderViewModel(),
);

class OrderViewModel extends Notifier<OrderState> {
  late final CreateOrderUsecase _createOrder;
  late final BuyNowUsecase _buyNow;
  late final GetUserOrdersUsecase _getUserOrders;
  late final GetOrderUsecase _getOrder;
  late final CancelOrderUsecase _cancelOrder;
  late final SubmitReceiptUsecase _submitReceipt;

  @override
  OrderState build() {
    _createOrder = ref.read(createOrderUsecaseProvider);
    _buyNow = ref.read(buyNowUsecaseProvider);
    _getUserOrders = ref.read(getUserOrdersUsecaseProvider);
    _getOrder = ref.read(getOrderUsecaseProvider);
    _cancelOrder = ref.read(cancelOrderUsecaseProvider);
    _submitReceipt = ref.read(submitReceiptUsecaseProvider);
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
    final result = await _createOrder(
      CreateOrderParams(
        storeId: storeId,
        pickupDate: pickupDate,
        pickupTime: pickupTime,
        notes: notes,
      ),
    );
    return result.fold(
      (f) {
        state = state.copyWith(
          status: OrderStatus.error,
          errorMessage: f.message,
        );
        return false;
      },
      (order) {
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
    final result = await _buyNow(
      BuyNowParams(
        productId: productId,
        quantity: quantity,
        storeId: storeId,
        pickupDate: pickupDate,
        pickupTime: pickupTime,
        notes: notes,
      ),
    );
    return result.fold(
      (f) {
        state = state.copyWith(
          status: OrderStatus.error,
          errorMessage: f.message,
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
    final result = await _getUserOrders();
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
    final result = await _submitReceipt(
      SubmitReceiptParams(
        orderId: orderId,
        receiptImagePath: receiptImagePath,
        paymentMethod: paymentMethod,
        notes: notes,
      ),
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
    final result = await _getOrder(orderId);
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
    final result = await _cancelOrder(
      CancelOrderParams(orderId: orderId, reason: reason),
    );
    return result.fold(
      (f) {
        state = state.copyWith(
          status: OrderStatus.error,
          errorMessage: f.message,
        );
        return false;
      },
      (order) {
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
