import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/core/usecases/app_usecase.dart';
import 'package:project_ease/features/rating/data/repositories/rating_repository.dart';
import 'package:project_ease/features/rating/domain/entitties/rating_entity.dart';
import 'package:project_ease/features/rating/domain/repositories/rating_repository.dart';

final createRatingUsecaseProvider = Provider<CreateRatingUsecase>(
  (ref) => CreateRatingUsecase(repo: ref.read(ratingRepositoryProvider)),
);

class CreateRatingParams extends Equatable {
  final String productId;
  final int rating;
  final String review;

  const CreateRatingParams({
    required this.productId,
    required this.rating,
    required this.review,
  });

  @override
  List<Object?> get props => [productId, rating, review];
}

class CreateRatingUsecase
    implements UsecaseWithParams<RatingEntity, CreateRatingParams> {
  final IRatingRepository _repo;
  CreateRatingUsecase({required IRatingRepository repo}) : _repo = repo;

  @override
  Future<Either<Failure, RatingEntity>> call(CreateRatingParams params) =>
      _repo.createRating(
        productId: params.productId,
        rating: params.rating,
        review: params.review,
      );
}
