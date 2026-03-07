import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/core/usecases/app_usecase.dart';
import 'package:project_ease/features/order/data/repositories/order_repository.dart';
import 'package:project_ease/features/order/domain/entities/order_entity.dart';
import 'package:project_ease/features/order/domain/repositories/order_repository.dart';

final getOrderUsecaseProvider = Provider<GetOrderUsecase>(
  (ref) => GetOrderUsecase(ref.read(orderRepositoryProvider)),
);

class GetOrderUsecase implements UsecaseWithParams<OrderEntity, String> {
  final IOrderRepository _repo;
  GetOrderUsecase(this._repo);

  @override
  Future<Either<Failure, OrderEntity>> call(String orderId) =>
      _repo.getOrder(orderId);
}
