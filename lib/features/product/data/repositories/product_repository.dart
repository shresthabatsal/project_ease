import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/features/product/data/datasources/local/product_local_datasource.dart';
import 'package:project_ease/features/product/data/datasources/product_datasource.dart';
import 'package:project_ease/features/product/domain/entities/category_entity.dart';
import 'package:project_ease/features/product/domain/entities/product_entity.dart';
import 'package:project_ease/features/product/domain/repositories/product_repository.dart';

final productRepositoryProvider = Provider<IProductRepository>(
  (ref) => ProductRepository(
    remoteDatasource: ref.read(productRemoteDatasourceProvider),
    localDatasource: ref.read(productLocalDatasourceProvider),
  ),
);

class ProductRepository implements IProductRepository {
  final IProductRemoteDatasource _remote;
  final ProductLocalDatasource _local;

  ProductRepository({
    required IProductRemoteDatasource remoteDatasource,
    required ProductLocalDatasource localDatasource,
  }) : _remote = remoteDatasource,
       _local = localDatasource;

  // Error handling
  String _extractErrorMessage(DioException e, String fallback) {
    try {
      final data = e.response?.data;
      if (data == null) return fallback;
      if (data is Map) return data['message'] ?? fallback;
      if (data is String) {
        final decoded = jsonDecode(data);
        if (decoded is Map) return decoded['message'] ?? fallback;
      }
    } catch (_) {}
    return fallback;
  }

  Either<Failure, T> _handleError<T>(
    Object e, [
    String fallback = 'Request failed.',
  ]) {
    if (e is DioException) {
      return Left(
        ApiFailure(
          message: _extractErrorMessage(e, fallback),
          statusCode: e.response?.statusCode,
        ),
      );
    }
    return Left(ApiFailure(message: e.toString()));
  }

  // Products by store
  @override
  Future<Either<Failure, List<ProductEntity>>> getProductsByStore(
    String storeId,
  ) async {
    try {
      final models = await _remote.getProductsByStore(storeId);
      // Save fresh data to cache
      await _local.saveProductsForStore(storeId, models);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      // Network failed, try cache
      try {
        final cached = await _local.getProductsForStore(storeId);
        if (cached.isNotEmpty) {
          return Right(cached.map((m) => m.toEntity()).toList());
        }
      } catch (_) {}
      return _handleError(e, 'Failed to load products for store.');
    }
  }

  // Products by category, not cached
  @override
  Future<Either<Failure, List<ProductEntity>>> getProductsByStoreAndCategory(
    String storeId,
    String categoryId,
  ) async {
    try {
      final models = await _remote.getProductsByStoreAndCategory(
        storeId,
        categoryId,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      // Fallback
      try {
        final cached = await _local.getProductsForStore(storeId);
        final filtered = cached
            .where((m) => m.categoryId == categoryId)
            .map((m) => m.toEntity())
            .toList();
        if (filtered.isNotEmpty) return Right(filtered);
      } catch (_) {}
      return _handleError(e, 'Failed to load products for category.');
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getProductsByStoreAndSubcategory(
    String storeId,
    String subcategoryId,
  ) async {
    try {
      final models = await _remote.getProductsByStoreAndSubcategory(
        storeId,
        subcategoryId,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      // Fallback: filter cached store products by subcategoryId
      try {
        final cached = await _local.getProductsForStore(storeId);
        final filtered = cached
            .where((m) => m.subcategoryId == subcategoryId)
            .map((m) => m.toEntity())
            .toList();
        if (filtered.isNotEmpty) return Right(filtered);
      } catch (_) {}
      return _handleError(e, 'Failed to load products for subcategory.');
    }
  }

  @override
  Future<Either<Failure, PaginatedProducts>> getAllProducts({
    String? search,
    int page = 1,
    int size = 10,
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
  }) async {
    try {
      final result = await _remote.getAllProducts(
        search: search,
        page: page,
        size: size,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );
      return Right(
        PaginatedProducts(
          products: result.products.map((m) => m.toEntity()).toList(),
          page: result.page,
          totalPages: result.totalPages,
          total: result.total,
        ),
      );
    } catch (e) {
      return _handleError(e, 'Failed to load products.');
    }
  }

  // Categories, cached

  @override
  Future<Either<Failure, List<CategoryEntity>>> getAllCategories() async {
    try {
      final models = await _remote.getAllCategories();
      // Save fresh data to cache
      await _local.saveCategories(models);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      // Network failed, try cache
      try {
        final cached = await _local.getCategories();
        if (cached.isNotEmpty) {
          return Right(cached.map((m) => m.toEntity()).toList());
        }
      } catch (_) {}
      return _handleError(e, 'Failed to load categories.');
    }
  }
}
