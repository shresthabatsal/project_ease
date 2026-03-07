import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/core/usecases/app_usecase.dart';
import 'package:project_ease/features/cart/data/repositories/cart_repository.dart';
import 'package:project_ease/features/cart/domain/repositories/cart_repository.dart';

final clearCartUsecaseProvider = Provider<ClearCartUsecase>(
  (ref) => ClearCartUsecase(ref.read(cartRepositoryProvider)),
);

class ClearCartUsecase implements UsecaseWithoutParams<void> {
  final ICartRepository _repo;
  ClearCartUsecase(this._repo);

  @override
  Future<Either<Failure, void>> call() => _repo.clearCart();
}
