import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/core/usecases/app_usecase.dart';
import 'package:project_ease/features/order/data/repositories/order_repository.dart';
import 'package:project_ease/features/order/domain/entities/order_entity.dart';
import 'package:project_ease/features/order/domain/repositories/order_repository.dart';

final getUserOrdersUsecaseProvider = Provider<GetUserOrdersUsecase>(
  (ref) => GetUserOrdersUsecase(ref.read(orderRepositoryProvider)),
);

class GetUserOrdersUsecase implements UsecaseWithoutParams<List<OrderEntity>> {
  final IOrderRepository _repo;
  GetUserOrdersUsecase(this._repo);

  @override
  Future<Either<Failure, List<OrderEntity>>> call() => _repo.getUserOrders();
}
