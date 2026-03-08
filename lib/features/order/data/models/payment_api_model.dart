import 'package:project_ease/features/order/domain/entities/payment_entity.dart';

class PaymentApiModel {
  final String id;
  final String orderId;
  final String status;
  final String? receiptUrl;
  final String? paymentMethod;
  final String? notes;
  final DateTime createdAt;

  PaymentApiModel({
    required this.id,
    required this.orderId,
    required this.status,
    this.receiptUrl,
    this.paymentMethod,
    this.notes,
    required this.createdAt,
  });

  factory PaymentApiModel.fromJson(Map<String, dynamic> json) {
    final orderRaw = json['orderId'];
    return PaymentApiModel(
      id: json['_id'] ?? '',
      orderId: orderRaw is Map ? (orderRaw['_id'] ?? '') : (orderRaw ?? ''),
      status: json['status'] ?? 'PENDING',
      receiptUrl: json['receiptUrl'],
      paymentMethod: json['paymentMethod'],
      notes: json['notes'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  PaymentEntity toEntity() => PaymentEntity(
    paymentId: id,
    orderId: orderId,
    status: status,
    receiptUrl: receiptUrl,
    paymentMethod: paymentMethod,
    notes: notes,
    createdAt: createdAt,
  );
}
