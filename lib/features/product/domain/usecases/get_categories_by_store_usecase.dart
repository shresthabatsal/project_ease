import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/features/product/data/repositories/product_repository.dart';
import 'package:project_ease/features/product/domain/entities/category_entity.dart';
import 'package:project_ease/features/product/domain/entities/product_entity.dart';
import 'package:project_ease/features/product/domain/repositories/product_repository.dart';

final getCategoriesByStoreUsecaseProvider =
    Provider<GetCategoriesByStoreUsecase>(
      (ref) => GetCategoriesByStoreUsecase(
        repository: ref.read(productRepositoryProvider),
      ),
    );

class GetCategoriesByStoreUsecase {
  final IProductRepository _repo;
  GetCategoriesByStoreUsecase({required IProductRepository repository})
    : _repo = repository;

  Future<Either<Failure, List<CategoryEntity>>> call(
    String storeId,
    List<ProductEntity> storeProducts,
  ) async {
    final result = await _repo.getAllCategories();
    return result.map((categories) {
      final categoryIdsInStore = storeProducts
          .where((p) => p.categoryId != null)
          .map((p) => p.categoryId!)
          .toSet();
      if (categoryIdsInStore.isEmpty) return categories;
      return categories
          .where((c) => categoryIdsInStore.contains(c.categoryId))
          .toList();
    });
  }
}
