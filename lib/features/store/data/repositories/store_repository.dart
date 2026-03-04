import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/features/store/data/datasources/remote/store_remote_datasource.dart';
import 'package:project_ease/features/store/domain/entities/store_entity.dart';
import 'package:project_ease/features/store/domain/repositories/store_repository.dart';

final storeRepositoryProvider = Provider<IStoreRepository>(
  (ref) => StoreRepository(
    remoteDatasource: ref.read(storeRemoteDatasourceProvider),
  ),
);

class StoreRepository implements IStoreRepository {
  final IStoreRemoteDatasource _remote;
  StoreRepository({required IStoreRemoteDatasource remoteDatasource})
    : _remote = remoteDatasource;

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

  Either<Failure, T> _handleError<T>(Object e, String fallback) {
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

  @override
  Future<Either<Failure, List<StoreEntity>>> getAllStores() async {
    try {
      final models = await _remote.getAllStores();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return _handleError(e, 'Failed to load stores');
    }
  }

  @override
  Future<Either<Failure, List<StoreEntity>>> getNearestStores({
    required double latitude,
    required double longitude,
    double maxDistance = 50,
  }) async {
    try {
      final models = await _remote.getNearestStores(
        latitude: latitude,
        longitude: longitude,
        maxDistance: maxDistance,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return _handleError(e, 'Failed to load nearest stores');
    }
  }
}
