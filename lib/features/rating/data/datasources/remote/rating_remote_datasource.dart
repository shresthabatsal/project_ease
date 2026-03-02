import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/api/api_client.dart';
import 'package:project_ease/core/api/api_endpoints.dart';
import 'package:project_ease/features/rating/data/models/rating_api_model.dart';

final ratingRemoteDatasourceProvider = Provider<RatingRemoteDatasource>(
  (ref) => RatingRemoteDatasource(apiClient: ref.read(apiClientProvider)),
);

class RatingRemoteDatasource {
  final ApiClient _apiClient;
  RatingRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  Future<RatingSummaryApiModel> getRatingsByProduct(String productId) async {
    final res = await _apiClient.get(
      ApiEndpoints.getRatingsByProduct(productId),
    );
    return RatingSummaryApiModel.fromJson(
      res.data['data'] as Map<String, dynamic>,
    );
  }

  Future<RatingApiModel> createRating({
    required String productId,
    required int rating,
    required String review,
  }) async {
    final res = await _apiClient.post(
      ApiEndpoints.createRating,
      data: {'productId': productId, 'rating': rating, 'review': review},
    );
    return RatingApiModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<RatingApiModel> updateRating({
    required String ratingId,
    required int rating,
    required String review,
  }) async {
    final res = await _apiClient.put(
      ApiEndpoints.updateRating(ratingId),
      data: {'rating': rating, 'review': review},
    );
    return RatingApiModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<void> deleteRating(String ratingId) async {
    await _apiClient.delete(ApiEndpoints.deleteRating(ratingId));
  }
}
