import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/features/cart/data/datasources/remote/cart_remote_datasource.dart';
import 'package:project_ease/features/cart/domain/entities/cart_entity.dart';
import 'package:project_ease/features/cart/domain/repositories/cart_repository.dart';

final cartRepositoryProvider = Provider<ICartRepository>(
  (ref) => CartRepository(remote: ref.read(cartRemoteDatasourceProvider)),
);

class CartRepository implements ICartRepository {
  final CartRemoteDatasource _remote;
  CartRepository({required CartRemoteDatasource remote}) : _remote = remote;

  String _extractError(DioException e, String fallback) {
    try {
      final data = e.response?.data;
      if (data == null) return fallback;
      if (data is Map) return data['message']?.toString() ?? fallback;
      if (data is String) {
        final decoded = jsonDecode(data);
        if (decoded is Map) return decoded['message']?.toString() ?? fallback;
      }
    } catch (_) {}
    return fallback;
  }

  Either<Failure, T> _handleError<T>(Object e, String fallback) {
    if (e is DioException) {
      return Left(
        ApiFailure(
          message: _extractError(e, fallback),
          statusCode: e.response?.statusCode,
        ),
      );
    }
    return Left(ApiFailure(message: e.toString()));
  }

  @override
  Future<Either<Failure, List<CartItemEntity>>> getCart() async {
    try {
      final models = await _remote.getCart();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return _handleError(e, 'Failed to load cart.');
    }
  }

  @override
  Future<Either<Failure, void>> addToCart({
    required String productId,
    required int quantity,
  }) async {
    try {
      await _remote.addToCart(productId: productId, quantity: quantity);
      return const Right(null);
    } catch (e) {
      return _handleError(e, 'Failed to add item to cart.');
    }
  }

  @override
  Future<Either<Failure, CartItemEntity>> updateCartItem({
    required String cartItemId,
    required int quantity,
  }) async {
    try {
      final model = await _remote.updateCartItem(
        cartItemId: cartItemId,
        quantity: quantity,
      );
      return Right(model.toEntity());
    } catch (e) {
      return _handleError(e, 'Failed to update cart item.');
    }
  }

  @override
  Future<Either<Failure, void>> removeFromCart(String cartItemId) async {
    try {
      await _remote.removeFromCart(cartItemId);
      return const Right(null);
    } catch (e) {
      return _handleError(e, 'Failed to remove item.');
    }
  }

  @override
  Future<Either<Failure, void>> clearCart() async {
    try {
      await _remote.clearCart();
      return const Right(null);
    } catch (e) {
      return _handleError(e, 'Failed to clear cart.');
    }
  }
}
