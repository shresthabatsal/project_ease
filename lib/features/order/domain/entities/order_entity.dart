import 'package:equatable/equatable.dart';

class OrderItemEntity extends Equatable {
  final String productId;
  final String productName;
  final int quantity;
  final double price;

  const OrderItemEntity({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  double get subtotal => price * quantity;

  @override
  List<Object?> get props => [productId, quantity, price];
}

class OrderEntity extends Equatable {
  final String orderId;
  final String storeId;
  final String? storeName;
  final List<OrderItemEntity> items;
  final double totalAmount;
  final String pickupCode;
  final String? notes;
  final DateTime pickupDate;
  final String pickupTime;
  final String paymentStatus; // PENDING, VERIFIED, FAILED
  final String
  status; // PENDING, CONFIRMED, READY_FOR_COLLECTION, COLLECTED, CANCELLED
  final DateTime orderDate;

  const OrderEntity({
    required this.orderId,
    required this.storeId,
    this.storeName,
    required this.items,
    required this.totalAmount,
    required this.pickupCode,
    this.notes,
    required this.pickupDate,
    required this.pickupTime,
    required this.paymentStatus,
    required this.status,
    required this.orderDate,
  });

  @override
  List<Object?> get props => [orderId, status, paymentStatus];
}
