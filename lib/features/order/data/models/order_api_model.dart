import 'package:project_ease/features/order/domain/entities/order_entity.dart';

class OrderItemApiModel {
  final String productId;
  final String productName;
  final int quantity;
  final double price;

  OrderItemApiModel({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  factory OrderItemApiModel.fromJson(Map<String, dynamic> json) {
    final productRaw = json['productId'];
    return OrderItemApiModel(
      productId: productRaw is Map
          ? (productRaw['_id'] ?? '')
          : (productRaw ?? ''),
      productName: productRaw is Map ? (productRaw['name'] ?? '') : '',
      quantity: json['quantity'] ?? 1,
      price: (json['price'] ?? 0).toDouble(),
    );
  }

  OrderItemEntity toEntity() => OrderItemEntity(
    productId: productId,
    productName: productName,
    quantity: quantity,
    price: price,
  );
}

class OrderApiModel {
  final String id;
  final String storeId;
  final String? storeName;
  final List<OrderItemApiModel> items;
  final double totalAmount;
  final String pickupCode;
  final String? notes;
  final DateTime pickupDate;
  final String pickupTime;
  final String paymentStatus;
  final String status;
  final DateTime orderDate;

  OrderApiModel({
    required this.id,
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

  factory OrderApiModel.fromJson(Map<String, dynamic> json) {
    final storeRaw = json['storeId'];
    final itemsRaw = json['items'] as List? ?? [];

    return OrderApiModel(
      id: json['_id'] ?? '',
      storeId: storeRaw is Map ? (storeRaw['_id'] ?? '') : (storeRaw ?? ''),
      storeName: storeRaw is Map ? storeRaw['storeName'] : null,
      items: itemsRaw
          .map((i) => OrderItemApiModel.fromJson(i as Map<String, dynamic>))
          .toList(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      pickupCode: json['pickupCode'] ?? '',
      notes: json['notes'],
      pickupDate: DateTime.tryParse(json['pickupDate'] ?? '') ?? DateTime.now(),
      pickupTime: json['pickupTime'] ?? '',
      paymentStatus: json['paymentStatus'] ?? 'PENDING',
      status: json['status'] ?? 'PENDING',
      orderDate: DateTime.tryParse(json['orderDate'] ?? '') ?? DateTime.now(),
    );
  }

  OrderEntity toEntity() => OrderEntity(
    orderId: id,
    storeId: storeId,
    storeName: storeName,
    items: items.map((i) => i.toEntity()).toList(),
    totalAmount: totalAmount,
    pickupCode: pickupCode,
    notes: notes,
    pickupDate: pickupDate,
    pickupTime: pickupTime,
    paymentStatus: paymentStatus,
    status: status,
    orderDate: orderDate,
  );
}
