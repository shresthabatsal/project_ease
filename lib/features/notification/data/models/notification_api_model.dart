import 'package:project_ease/features/notification/domain/entities/notification_entity.dart';

class NotificationApiModel {
  final String id;
  final String orderId;
  final String type;
  final String title;
  final String message;
  final String? otp;
  final String? pickupTime;
  final String? pickupDate;
  final bool isRead;
  final DateTime createdAt;

  NotificationApiModel({
    required this.id,
    required this.orderId,
    required this.type,
    required this.title,
    required this.message,
    this.otp,
    this.pickupTime,
    this.pickupDate,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationApiModel.fromJson(Map<String, dynamic> json) {
    final orderRaw = json['orderId'];
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return NotificationApiModel(
      id: json['_id'] ?? '',
      orderId: orderRaw is Map ? (orderRaw['_id'] ?? '') : (orderRaw ?? ''),
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      otp: data['otp'],
      pickupTime: data['pickupTime'],
      pickupDate: data['pickupDate'],
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  NotificationEntity toEntity() => NotificationEntity(
    id: id,
    orderId: orderId,
    type: _parseType(type),
    title: title,
    message: message,
    otp: otp,
    pickupTime: pickupTime,
    pickupDate: pickupDate,
    isRead: isRead,
    createdAt: createdAt,
  );

  static NotificationType _parseType(String raw) {
    return switch (raw) {
      'ORDER_CREATED' => NotificationType.orderCreated,
      'PAYMENT_VERIFIED' => NotificationType.paymentVerified,
      'ORDER_CONFIRMED' => NotificationType.orderConfirmed,
      'READY_FOR_COLLECTION' => NotificationType.readyForCollection,
      'COLLECTION_REMINDER' => NotificationType.collectionReminder,
      'ORDER_COLLECTED' => NotificationType.orderCollected,
      'ORDER_CANCELLED' => NotificationType.orderCancelled,
      'PAYMENT_REJECTED' => NotificationType.paymentRejected,
      _ => NotificationType.unknown,
    };
  }
}
