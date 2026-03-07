import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/core/usecases/app_usecase.dart';
import 'package:project_ease/features/order/data/repositories/order_repository.dart';
import 'package:project_ease/features/order/domain/entities/order_entity.dart';
import 'package:project_ease/features/order/domain/repositories/order_repository.dart';

final buyNowUsecaseProvider = Provider<BuyNowUsecase>(
  (ref) => BuyNowUsecase(ref.read(orderRepositoryProvider)),
);

class BuyNowParams {
  final String productId;
  final int quantity;
  final String storeId;
  final String pickupDate;
  final String pickupTime;
  final String? notes;
  const BuyNowParams({
    required this.productId,
    required this.quantity,
    required this.storeId,
    required this.pickupDate,
    required this.pickupTime,
    this.notes,
  });
}

class BuyNowUsecase implements UsecaseWithParams<OrderEntity, BuyNowParams> {
  final IOrderRepository _repo;
  BuyNowUsecase(this._repo);

  @override
  Future<Either<Failure, OrderEntity>> call(BuyNowParams params) =>
      _repo.buyNow(
        productId: params.productId,
        quantity: params.quantity,
        storeId: params.storeId,
        pickupDate: params.pickupDate,
        pickupTime: params.pickupTime,
        notes: params.notes,
      );
}
