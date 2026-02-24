import 'package:dartz/dartz.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/features/product/domain/entities/category_entity.dart';
import 'package:project_ease/features/product/domain/entities/product_entity.dart';

class PaginatedProducts {
  final List<ProductEntity> products;
  final int page;
  final int totalPages;
  final int total;

  const PaginatedProducts({
    required this.products,
    required this.page,
    required this.totalPages,
    required this.total,
  });
}

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
  Future<Either<Failure, PaginatedProducts>> getAllProducts({
    String? search,
    int page,
    int size,
    String sortBy,
    String sortOrder,
  });
  Future<Either<Failure, List<CategoryEntity>>> getAllCategories();
}
