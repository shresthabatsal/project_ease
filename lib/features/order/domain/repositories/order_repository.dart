import 'package:dartz/dartz.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/features/order/domain/entities/order_entity.dart';
import 'package:project_ease/features/order/domain/entities/payment_entity.dart';

abstract interface class IOrderRepository {
  Future<Either<Failure, OrderEntity>> createOrder({
    required String storeId,
    required String pickupDate,
    required String pickupTime,
    String? notes,
  });

  Future<Either<Failure, OrderEntity>> buyNow({
    required String productId,
    required int quantity,
    required String storeId,
    required String pickupDate,
    required String pickupTime,
    String? notes,
  });

  Future<Either<Failure, List<OrderEntity>>> getUserOrders();

  Future<Either<Failure, OrderEntity>> getOrder(String orderId);

  Future<Either<Failure, OrderEntity>> cancelOrder(
    String orderId,
    String? reason,
  );

  Future<Either<Failure, void>> submitReceipt({
    required String orderId,
    required String receiptImagePath,
    String? paymentMethod,
    String? notes,
  });

  Future<Either<Failure, PaymentEntity?>> getOrderPayment(String orderId);
}
