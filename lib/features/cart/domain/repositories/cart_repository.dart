import 'package:dartz/dartz.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/features/cart/domain/entities/cart_entity.dart';

abstract interface class ICartRepository {
  Future<Either<Failure, List<CartItemEntity>>> getCart();
  Future<Either<Failure, CartItemEntity>> addToCart({
    required String productId,
    required int quantity,
  });
  Future<Either<Failure, CartItemEntity>> updateCartItem({
    required String cartItemId,
    required int quantity,
  });
  Future<Either<Failure, void>> removeFromCart(String cartItemId);
  Future<Either<Failure, void>> clearCart();
}
