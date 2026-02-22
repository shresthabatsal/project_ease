import 'package:dartz/dartz.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/features/product/domain/entities/category_entity.dart';
import 'package:project_ease/features/product/domain/entities/product_entity.dart';

abstract interface class IProductRepository {
  Future<Either<Failure, List<ProductEntity>>> getProductsByStore(
    String storeId,
  );
  Future<Either<Failure, List<ProductEntity>>> getProductsByStoreAndCategory(
    String storeId,
    String categoryId,
  );
  Future<Either<Failure, List<ProductEntity>>> getProductsByStoreAndSubcategory(
    String storeId,
    String subcategoryId,
  );
  Future<Either<Failure, List<ProductEntity>>> getAllProducts({
    String? search,
    int page,
    int size,
  });
  Future<Either<Failure, List<CategoryEntity>>> getAllCategories();
}
