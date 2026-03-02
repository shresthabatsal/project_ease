import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/core/usecases/app_usecase.dart';
import 'package:project_ease/features/rating/data/repositories/rating_repository.dart';
import 'package:project_ease/features/rating/domain/repositories/rating_repository.dart';

final deleteRatingUsecaseProvider = Provider<DeleteRatingUsecase>(
  (ref) => DeleteRatingUsecase(repo: ref.read(ratingRepositoryProvider)),
);

class DeleteRatingUsecase implements UsecaseWithParams<void, String> {
  final IRatingRepository _repo;
  DeleteRatingUsecase({required IRatingRepository repo}) : _repo = repo;

  @override
  Future<Either<Failure, void>> call(String ratingId) =>
      _repo.deleteRating(ratingId);
}
