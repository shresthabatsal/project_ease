import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/core/usecases/app_usecase.dart';
import 'package:project_ease/features/order/data/repositories/order_repository.dart';
import 'package:project_ease/features/order/domain/entities/order_entity.dart';
import 'package:project_ease/features/order/domain/repositories/order_repository.dart';

final cancelOrderUsecaseProvider = Provider<CancelOrderUsecase>(
  (ref) => CancelOrderUsecase(ref.read(orderRepositoryProvider)),
);

class CancelOrderParams {
  final String orderId;
  final String? reason;
  const CancelOrderParams({required this.orderId, this.reason});
}

class CancelOrderUsecase
    implements UsecaseWithParams<OrderEntity, CancelOrderParams> {
  final IOrderRepository _repo;
  CancelOrderUsecase(this._repo);

  @override
  Future<Either<Failure, OrderEntity>> call(CancelOrderParams params) =>
      _repo.cancelOrder(params.orderId, params.reason);
}
