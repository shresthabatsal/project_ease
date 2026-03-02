import 'package:dartz/dartz.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/features/rating/domain/entitties/rating_entity.dart';

abstract interface class IRatingRepository {
  Future<Either<Failure, RatingSummaryEntity>> getRatingsByProduct(
    String productId,
  );
  Future<Either<Failure, RatingEntity>> createRating({
    required String productId,
    required int rating,
    required String review,
  });
  Future<Either<Failure, RatingEntity>> updateRating({
    required String ratingId,
    required int rating,
    required String review,
  });
  Future<Either<Failure, void>> deleteRating(String ratingId);
}
