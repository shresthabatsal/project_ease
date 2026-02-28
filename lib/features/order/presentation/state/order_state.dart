import 'package:equatable/equatable.dart';
import 'package:project_ease/features/order/domain/entities/order_entity.dart';

enum OrderStatus { initial, loading, success, error }

class OrderState extends Equatable {
  final OrderStatus status;
  final OrderEntity? currentOrder;
  final List<OrderEntity> orders;
  final String? errorMessage;

  const OrderState({
    this.status = OrderStatus.initial,
    this.currentOrder,
    this.orders = const [],
    this.errorMessage,
  });

  OrderState copyWith({
    OrderStatus? status,
    OrderEntity? currentOrder,
    bool clearCurrentOrder = false,
    List<OrderEntity>? orders,
    String? errorMessage,
  }) {
    return OrderState(
      status: status ?? this.status,
      currentOrder: clearCurrentOrder
          ? null
          : (currentOrder ?? this.currentOrder),
      orders: orders ?? this.orders,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, currentOrder, orders, errorMessage];
}