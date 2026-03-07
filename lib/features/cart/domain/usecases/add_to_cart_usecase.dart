import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/core/usecases/app_usecase.dart';
import 'package:project_ease/features/cart/data/repositories/cart_repository.dart';
import 'package:project_ease/features/cart/domain/repositories/cart_repository.dart';

final addToCartUsecaseProvider = Provider<AddToCartUsecase>(
  (ref) => AddToCartUsecase(ref.read(cartRepositoryProvider)),
);

class AddToCartParams {
  final String productId;
  final int quantity;
  const AddToCartParams({required this.productId, required this.quantity});
}

class AddToCartUsecase implements UsecaseWithParams<void, AddToCartParams> {
  final ICartRepository _repo;
  AddToCartUsecase(this._repo);

  @override
  Future<Either<Failure, void>> call(AddToCartParams params) =>
      _repo.addToCart(productId: params.productId, quantity: params.quantity);
}
