import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/features/rating/data/datasources/remote/rating_remote_datasource.dart';
import 'package:project_ease/features/rating/domain/entitties/rating_entity.dart';
import 'package:project_ease/features/rating/domain/repositories/rating_repository.dart';

final ratingRepositoryProvider = Provider<IRatingRepository>(
  (ref) => RatingRepository(remote: ref.read(ratingRemoteDatasourceProvider)),
);

class RatingRepository implements IRatingRepository {
  final RatingRemoteDatasource _remote;
  RatingRepository({required RatingRemoteDatasource remote}) : _remote = remote;

  Either<Failure, T> _handleError<T>(Object e, String fallback) {
    if (e is DioException) {
      final msg = (e.response?.data is Map)
          ? e.response?.data['message'] ?? fallback
          : fallback;
      return Left(ApiFailure(message: msg, statusCode: e.response?.statusCode));
    }
    return Left(ApiFailure(message: e.toString()));
  }

  @override
  Future<Either<Failure, RatingSummaryEntity>> getRatingsByProduct(
    String productId,
  ) async {
    try {
      final model = await _remote.getRatingsByProduct(productId);
      return Right(model.toEntity());
    } catch (e) {
      return _handleError(e, 'Failed to load ratings');
    }
  }

  @override
  Future<Either<Failure, RatingEntity>> createRating({
    required String productId,
    required int rating,
    required String review,
  }) async {
    try {
      final model = await _remote.createRating(
        productId: productId,
        rating: rating,
        review: review,
      );
      return Right(model.toEntity());
    } catch (e) {
      return _handleError(e, 'Failed to submit rating');
    }
  }

  @override
  Future<Either<Failure, RatingEntity>> updateRating({
    required String ratingId,
    required int rating,
    required String review,
  }) async {
    try {
      final model = await _remote.updateRating(
        ratingId: ratingId,
        rating: rating,
        review: review,
      );
      return Right(model.toEntity());
    } catch (e) {
      return _handleError(e, 'Failed to update rating');
    }
  }

  @override
  Future<Either<Failure, void>> deleteRating(String ratingId) async {
    try {
      await _remote.deleteRating(ratingId);
      return const Right(null);
    } catch (e) {
      return _handleError(e, 'Failed to delete rating');
    }
  }
}
