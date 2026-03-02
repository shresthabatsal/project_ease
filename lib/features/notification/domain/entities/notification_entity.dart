import 'package:equatable/equatable.dart';

enum NotificationType {
  orderCreated,
  paymentVerified,
  orderConfirmed,
  readyForCollection,
  collectionReminder,
  orderCollected,
  orderCancelled,
  paymentRejected,
  unknown,
}

class NotificationEntity extends Equatable {
  final String id;
  final String orderId;
  final NotificationType type;
  final String title;
  final String message;
  final String? otp;
  final String? pickupTime;
  final String? pickupDate;
  final bool isRead;
  final DateTime createdAt;

  const NotificationEntity({
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

  NotificationEntity copyWith({bool? isRead}) => NotificationEntity(
    id: id,
    orderId: orderId,
    type: type,
    title: title,
    message: message,
    otp: otp,
    pickupTime: pickupTime,
    pickupDate: pickupDate,
    isRead: isRead ?? this.isRead,
    createdAt: createdAt,
  );

  @override
  List<Object?> get props => [id, isRead];
}
