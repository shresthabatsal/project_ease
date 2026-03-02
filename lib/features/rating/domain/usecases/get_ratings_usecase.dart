import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/core/usecases/app_usecase.dart';
import 'package:project_ease/features/rating/data/repositories/rating_repository.dart';
import 'package:project_ease/features/rating/domain/entitties/rating_entity.dart';
import 'package:project_ease/features/rating/domain/repositories/rating_repository.dart';

final getRatingsUsecaseProvider = Provider<GetRatingsUsecase>(
  (ref) => GetRatingsUsecase(repo: ref.read(ratingRepositoryProvider)),
);

class GetRatingsUsecase
    implements UsecaseWithParams<RatingSummaryEntity, String> {
  final IRatingRepository _repo;
  GetRatingsUsecase({required IRatingRepository repo}) : _repo = repo;

  @override
  Future<Either<Failure, RatingSummaryEntity>> call(String productId) =>
      _repo.getRatingsByProduct(productId);
}
