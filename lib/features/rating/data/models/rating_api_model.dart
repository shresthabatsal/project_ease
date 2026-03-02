import 'package:project_ease/features/rating/domain/entitties/rating_entity.dart';

class RatingApiModel {
  final String id;
  final String productId;
  final String userId;
  final String? userName;
  final int rating;
  final String review;
  final DateTime createdAt;

  RatingApiModel({
    required this.id,
    required this.productId,
    required this.userId,
    this.userName,
    required this.rating,
    required this.review,
    required this.createdAt,
  });

  factory RatingApiModel.fromJson(Map<String, dynamic> json) {
    final userRaw = json['userId'];
    String userId = '';
    String? userName;
    if (userRaw is Map) {
      userId = userRaw['_id'] ?? '';
      userName = userRaw['name'] ?? userRaw['fullName'];
    } else {
      userId = userRaw?.toString() ?? '';
    }

    final productRaw = json['productId'];
    final productId = productRaw is Map
        ? (productRaw['_id'] ?? '')
        : (productRaw?.toString() ?? '');

    return RatingApiModel(
      id: json['_id'] ?? '',
      productId: productId,
      userId: userId,
      userName: userName,
      rating: (json['rating'] as num).toInt(),
      review: json['review'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  RatingEntity toEntity() => RatingEntity(
    ratingId: id,
    productId: productId,
    userId: userId,
    userName: userName,
    rating: rating,
    review: review,
    createdAt: createdAt,
  );
}

class RatingSummaryApiModel {
  final List<RatingApiModel> ratings;
  final double averageRating;
  final int totalRatings;

  RatingSummaryApiModel({
    required this.ratings,
    required this.averageRating,
    required this.totalRatings,
  });

  factory RatingSummaryApiModel.fromJson(Map<String, dynamic> json) {
    final list = (json['ratings'] as List? ?? [])
        .map((e) => RatingApiModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return RatingSummaryApiModel(
      ratings: list,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalRatings: (json['totalRatings'] as num?)?.toInt() ?? list.length,
    );
  }

  RatingSummaryEntity toEntity() => RatingSummaryEntity(
    ratings: ratings.map((r) => r.toEntity()).toList(),
    averageRating: averageRating,
    totalRatings: totalRatings,
  );
}
