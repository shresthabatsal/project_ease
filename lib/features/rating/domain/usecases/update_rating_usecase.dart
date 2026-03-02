import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/core/usecases/app_usecase.dart';
import 'package:project_ease/features/rating/data/repositories/rating_repository.dart';
import 'package:project_ease/features/rating/domain/entitties/rating_entity.dart';
import 'package:project_ease/features/rating/domain/repositories/rating_repository.dart';

final updateRatingUsecaseProvider = Provider<UpdateRatingUsecase>(
  (ref) => UpdateRatingUsecase(repo: ref.read(ratingRepositoryProvider)),
);

class UpdateRatingParams extends Equatable {
  final String ratingId;
  final int rating;
  final String review;

  const UpdateRatingParams({
    required this.ratingId,
    required this.rating,
    required this.review,
  });

  @override
  List<Object?> get props => [ratingId, rating, review];
}

class UpdateRatingUsecase
    implements UsecaseWithParams<RatingEntity, UpdateRatingParams> {
  final IRatingRepository _repo;
  UpdateRatingUsecase({required IRatingRepository repo}) : _repo = repo;

  @override
  Future<Either<Failure, RatingEntity>> call(UpdateRatingParams params) =>
      _repo.updateRating(
        ratingId: params.ratingId,
        rating: params.rating,
        review: params.review,
      );
}
