import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/features/product/data/repositories/product_repository.dart';
import 'package:project_ease/features/product/domain/entities/product_entity.dart';
import 'package:project_ease/features/product/domain/repositories/product_repository.dart';

final getProductsByStoreCategoryUsecaseProvider =
    Provider<GetProductsByStoreCategoryUsecase>(
      (ref) => GetProductsByStoreCategoryUsecase(
        repository: ref.read(productRepositoryProvider),
      ),
    );

class GetProductsByStoreCategoryUsecaseParams extends Equatable {
  final String storeId;
  final String categoryId;
  const GetProductsByStoreCategoryUsecaseParams({
    required this.storeId,
    required this.categoryId,
  });
  @override
  List<Object?> get props => [storeId, categoryId];
}

class GetProductsByStoreCategoryUsecase {
  final IProductRepository _repo;
  GetProductsByStoreCategoryUsecase({required IProductRepository repository})
    : _repo = repository;

  Future<Either<Failure, List<ProductEntity>>> call(
    GetProductsByStoreCategoryUsecaseParams params,
  ) => _repo.getProductsByStoreAndCategory(params.storeId, params.categoryId);
}
