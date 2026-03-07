import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/core/usecases/app_usecase.dart';
import 'package:project_ease/features/order/data/repositories/order_repository.dart';
import 'package:project_ease/features/order/domain/entities/order_entity.dart';
import 'package:project_ease/features/order/domain/repositories/order_repository.dart';

final createOrderUsecaseProvider = Provider<CreateOrderUsecase>(
  (ref) => CreateOrderUsecase(ref.read(orderRepositoryProvider)),
);

class CreateOrderParams {
  final String storeId;
  final String pickupDate;
  final String pickupTime;
  final String? notes;
  const CreateOrderParams({
    required this.storeId,
    required this.pickupDate,
    required this.pickupTime,
    this.notes,
  });
}

class CreateOrderUsecase
    implements UsecaseWithParams<OrderEntity, CreateOrderParams> {
  final IOrderRepository _repo;
  CreateOrderUsecase(this._repo);

  @override
  Future<Either<Failure, OrderEntity>> call(CreateOrderParams params) =>
      _repo.createOrder(
        storeId: params.storeId,
        pickupDate: params.pickupDate,
        pickupTime: params.pickupTime,
        notes: params.notes,
      );
}
