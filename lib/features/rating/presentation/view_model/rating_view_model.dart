import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/features/rating/domain/entitties/rating_entity.dart';
import 'package:project_ease/features/rating/domain/usecases/create_rating_usecase.dart';
import 'package:project_ease/features/rating/domain/usecases/delete_rating_usecase.dart';
import 'package:project_ease/features/rating/domain/usecases/get_ratings_usecase.dart';
import 'package:project_ease/features/rating/domain/usecases/update_rating_usecase.dart';
import 'package:project_ease/features/rating/presentation/state/rating_state.dart';

final ratingViewModelProvider = NotifierProvider<RatingViewModel, RatingState>(
  () => RatingViewModel(),
);

class RatingViewModel extends Notifier<RatingState> {
  late final GetRatingsUsecase _getRatings;
  late final CreateRatingUsecase _createRating;
  late final UpdateRatingUsecase _updateRating;
  late final DeleteRatingUsecase _deleteRating;

  @override
  RatingState build() {
    _getRatings = ref.read(getRatingsUsecaseProvider);
    _createRating = ref.read(createRatingUsecaseProvider);
    _updateRating = ref.read(updateRatingUsecaseProvider);
    _deleteRating = ref.read(deleteRatingUsecaseProvider);
    return const RatingState();
  }

  Future<void> loadRatings(String productId, {String? currentUserId}) async {
    state = state.copyWith(status: RatingStatus.loading);
    final result = await _getRatings(productId);
    result.fold(
      (f) => state = state.copyWith(
        status: RatingStatus.error,
        errorMessage: f.message,
      ),
      (summary) => state = state.copyWith(
        status: RatingStatus.success,
        ratings: summary.ratings,
        averageRating: summary.averageRating,
        totalRatings: summary.totalRatings,
        currentUserId: currentUserId,
      ),
    );
  }

  Future<bool> submitRating({
    required String productId,
    required int rating,
    required String review,
  }) async {
    state = state.copyWith(status: RatingStatus.submitting);
    final result = await _createRating(
      CreateRatingParams(productId: productId, rating: rating, review: review),
    );
    return result.fold(
      (f) {
        state = state.copyWith(
          status: RatingStatus.error,
          errorMessage: f.message,
        );
        return false;
      },
      (newRating) {
        final updated = [newRating, ...state.ratings];
        state = state.copyWith(
          status: RatingStatus.success,
          ratings: updated,
          averageRating: _calcAverage(updated),
          totalRatings: updated.length,
        );
        return true;
      },
    );
  }

  Future<bool> updateRating({
    required String ratingId,
    required int rating,
    required String review,
  }) async {
    state = state.copyWith(status: RatingStatus.submitting);
    final result = await _updateRating(
      UpdateRatingParams(ratingId: ratingId, rating: rating, review: review),
    );
    return result.fold(
      (f) {
        state = state.copyWith(
          status: RatingStatus.error,
          errorMessage: f.message,
        );
        return false;
      },
      (updated) {
        final list = state.ratings
            .map((r) => r.ratingId == ratingId ? updated : r)
            .toList();
        state = state.copyWith(
          status: RatingStatus.success,
          ratings: list,
          averageRating: _calcAverage(list),
        );
        return true;
      },
    );
  }

  Future<bool> deleteRating(String ratingId) async {
    state = state.copyWith(status: RatingStatus.submitting);
    final result = await _deleteRating(ratingId);
    return result.fold(
      (f) {
        state = state.copyWith(
          status: RatingStatus.error,
          errorMessage: f.message,
        );
        return false;
      },
      (_) {
        final list = state.ratings
            .where((r) => r.ratingId != ratingId)
            .toList();
        state = state.copyWith(
          status: RatingStatus.success,
          ratings: list,
          averageRating: _calcAverage(list),
          totalRatings: list.length,
        );
        return true;
      },
    );
  }

  double _calcAverage(List<RatingEntity> list) => list.isEmpty
      ? 0.0
      : list.map((r) => r.rating).reduce((a, b) => a + b) / list.length;
}
