import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/core/usecases/app_usecase.dart';
import 'package:project_ease/features/cart/data/repositories/cart_repository.dart';
import 'package:project_ease/features/cart/domain/entities/cart_entity.dart';
import 'package:project_ease/features/cart/domain/repositories/cart_repository.dart';

final updateCartItemUsecaseProvider = Provider<UpdateCartItemUsecase>(
  (ref) => UpdateCartItemUsecase(ref.read(cartRepositoryProvider)),
);

class UpdateCartItemParams {
  final String cartItemId;
  final int quantity;
  const UpdateCartItemParams({
    required this.cartItemId,
    required this.quantity,
  });
}

class UpdateCartItemUsecase
    implements UsecaseWithParams<CartItemEntity, UpdateCartItemParams> {
  final ICartRepository _repo;
  UpdateCartItemUsecase(this._repo);

  @override
  Future<Either<Failure, CartItemEntity>> call(UpdateCartItemParams params) =>
      _repo.updateCartItem(
        cartItemId: params.cartItemId,
        quantity: params.quantity,
      );
}
