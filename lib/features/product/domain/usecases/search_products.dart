import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/features/product/data/repositories/product_repository.dart';
import 'package:project_ease/features/product/domain/entities/product_entity.dart';
import 'package:project_ease/features/product/domain/repositories/product_repository.dart';

class PaginatedProductResult {
  final List<ProductEntity> products;
  final int page;
  final int totalPages;
  final int total;

  const PaginatedProductResult({
    required this.products,
    required this.page,
    required this.totalPages,
    required this.total,
  });
}

final searchProductsUsecaseProvider = Provider<SearchProductsUsecase>(
  (ref) =>
      SearchProductsUsecase(repository: ref.read(productRepositoryProvider)),
);

class SearchProductsUsecaseParams extends Equatable {
  final String storeId;
  final String search;
  final int page;
  final int size;
  final String? subcategoryId;
  final double? minPrice;
  final double? maxPrice;
  final String sortBy;
  final String sortOrder;

  const SearchProductsUsecaseParams({
    required this.storeId,
    this.search = '',
    this.page = 1,
    this.size = 10,
    this.subcategoryId,
    this.minPrice,
    this.maxPrice,
    this.sortBy = 'createdAt',
    this.sortOrder = 'desc',
  });

  @override
  List<Object?> get props => [
    storeId,
    search,
    page,
    size,
    subcategoryId,
    minPrice,
    maxPrice,
    sortBy,
    sortOrder,
  ];
}

class SearchProductsUsecase {
  final IProductRepository _repo;
  SearchProductsUsecase({required IProductRepository repository})
    : _repo = repository;

  Future<Either<Failure, PaginatedProductResult>> call(
    SearchProductsUsecaseParams params,
  ) async {
    final result = await _repo.getAllProducts(
      search: params.search,
      page: params.page,
      size: params.size,
      sortBy: params.sortBy,
      sortOrder: params.sortOrder,
    );

    return result.map((data) {
      // Filter to selected store
      var products = data.products
          .where((p) => p.storeId == params.storeId)
          .toList();

      // Subcategory filter
      if (params.subcategoryId != null) {
        products = products
            .where((p) => p.subcategoryId == params.subcategoryId)
            .toList();
      }

      // Price range filter
      if (params.minPrice != null) {
        products = products.where((p) => p.price >= params.minPrice!).toList();
      }
      if (params.maxPrice != null) {
        products = products.where((p) => p.price <= params.maxPrice!).toList();
      }

      return PaginatedProductResult(
        products: products,
        page: data.page,
        totalPages: data.totalPages,
        total: data.total,
      );
    });
  }
}
