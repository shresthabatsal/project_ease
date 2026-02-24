import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/features/product/data/repositories/product_repository.dart';
import 'package:project_ease/features/product/domain/entities/product_entity.dart';
import 'package:project_ease/features/product/domain/repositories/product_repository.dart';

final getProductsByStoreUsecaseProvider = Provider<GetProductsByStoreUsecase>(
  (ref) => GetProductsByStoreUsecase(
    repository: ref.read(productRepositoryProvider),
  ),
);

class GetProductsByStoreUsecase {
  final IProductRepository _repo;
  GetProductsByStoreUsecase({required IProductRepository repository})
    : _repo = repository;

  Future<Either<Failure, List<ProductEntity>>> call(String storeId) =>
      _repo.getProductsByStore(storeId);
}
