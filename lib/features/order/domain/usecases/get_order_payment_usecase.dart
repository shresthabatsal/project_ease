import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/features/order/data/repositories/order_repository.dart';
import 'package:project_ease/features/order/domain/entities/payment_entity.dart';
import 'package:project_ease/features/order/domain/repositories/order_repository.dart';

final getOrderPaymentUsecaseProvider = Provider<GetOrderPaymentUsecase>(
  (ref) => GetOrderPaymentUsecase(ref.read(orderRepositoryProvider)),
);

class GetOrderPaymentUsecase {
  final IOrderRepository _repo;
  GetOrderPaymentUsecase(this._repo);

  Future<Either<Failure, PaymentEntity?>> call(String orderId) =>
      _repo.getOrderPayment(orderId);
}
