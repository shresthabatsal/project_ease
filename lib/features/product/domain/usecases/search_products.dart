import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/features/product/data/repositories/product_repository.dart';
import 'package:project_ease/features/product/domain/entities/product_entity.dart';
import 'package:project_ease/features/product/domain/repositories/product_repository.dart';

final searchProductsUsecaseProvider = Provider<SearchProductsUsecase>((ref) {
  return SearchProductsUsecase(repository: ref.read(productRepositoryProvider));
});

class SearchProductsUsecaseParams extends Equatable {
  final String storeId;
  final String search;
  final int page;
  final int size;

  const SearchProductsUsecaseParams({
    required this.storeId,
    this.search = '',
    this.page = 1,
    this.size = 20,
  });

  @override
  List<Object?> get props => [storeId, search, page, size];
}

class SearchProductsUsecase {
  final IProductRepository _repo;
  SearchProductsUsecase({required IProductRepository repository})
    : _repo = repository;

  Future<Either<Failure, List<ProductEntity>>> call(
    SearchProductsUsecaseParams params,
  ) async {
    final result = await _repo.getAllProducts(
      search: params.search,
      page: params.page,
      size: params.size,
    );
    // Filter results to the selected store only
    return result.map(
      (products) => products.where((p) => p.storeId == params.storeId).toList(),
    );
  }
}
