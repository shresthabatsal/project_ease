import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/core/usecases/app_usecase.dart';
import 'package:project_ease/features/cart/data/repositories/cart_repository.dart';
import 'package:project_ease/features/cart/domain/repositories/cart_repository.dart';

final removeCartItemUsecaseProvider = Provider<RemoveCartItemUsecase>(
  (ref) => RemoveCartItemUsecase(ref.read(cartRepositoryProvider)),
);

class RemoveCartItemUsecase implements UsecaseWithParams<void, String> {
  final ICartRepository _repo;
  RemoveCartItemUsecase(this._repo);

  @override
  Future<Either<Failure, void>> call(String cartItemId) =>
      _repo.removeFromCart(cartItemId);
}
