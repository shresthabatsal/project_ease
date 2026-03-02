import 'package:equatable/equatable.dart';

class RatingEntity extends Equatable {
  final String ratingId;
  final String productId;
  final String userId;
  final String? userName;
  final int rating; // 1–5
  final String review;
  final DateTime createdAt;

  const RatingEntity({
    required this.ratingId,
    required this.productId,
    required this.userId,
    this.userName,
    required this.rating,
    required this.review,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [ratingId, rating, review];
}

class RatingSummaryEntity extends Equatable {
  final List<RatingEntity> ratings;
  final double averageRating;
  final int totalRatings;

  const RatingSummaryEntity({
    required this.ratings,
    required this.averageRating,
    required this.totalRatings,
  });

  @override
  List<Object?> get props => [averageRating, totalRatings];
}
