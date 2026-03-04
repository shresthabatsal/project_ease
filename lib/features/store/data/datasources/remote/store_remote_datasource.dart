import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/api/api_client.dart';
import 'package:project_ease/core/api/api_endpoints.dart';
import 'package:project_ease/features/store/data/models/store_api_model.dart';

abstract interface class IStoreRemoteDatasource {
  Future<List<StoreApiModel>> getAllStores();
  Future<StoreApiModel?> getStoreById(String id);
  Future<List<StoreApiModel>> getNearestStores({
    required double latitude,
    required double longitude,
    double maxDistance,
  });
}

final storeRemoteDatasourceProvider = Provider<IStoreRemoteDatasource>(
  (ref) => StoreRemoteDatasource(apiClient: ref.read(apiClientProvider)),
);

class StoreRemoteDatasource implements IStoreRemoteDatasource {
  final ApiClient _apiClient;
  StoreRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<StoreApiModel>> getAllStores() async {
    final response = await _apiClient.get(ApiEndpoints.getAllStores);
    if (response.data['success'] == true) {
      final List data = response.data['data'] as List;
      return data
          .map((e) => StoreApiModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<StoreApiModel?> getStoreById(String id) async {
    final response = await _apiClient.get(ApiEndpoints.getStoreById(id));
    if (response.data['success'] == true) {
      return StoreApiModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    }
    return null;
  }

  @override
  Future<List<StoreApiModel>> getNearestStores({
    required double latitude,
    required double longitude,
    double maxDistance = 50,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.getNearestStores,
      queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
        'maxDistance': maxDistance,
      },
    );
    if (response.data['success'] == true) {
      final List data = response.data['data'] as List;
      return data
          .map((e) => StoreApiModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
