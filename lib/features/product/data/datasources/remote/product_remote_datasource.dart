import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/api/api_client.dart';
import 'package:project_ease/core/api/api_endpoints.dart';
import 'package:project_ease/features/product/data/datasources/product_datasource.dart';
import 'package:project_ease/features/product/data/models/product_api_model.dart';

final productRemoteDatasourceProvider = Provider<IProductRemoteDatasource>((
  ref,
) {
  return ProductRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

class ProductRemoteDatasource implements IProductRemoteDatasource {
  final ApiClient _apiClient;
  ProductRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  List<ProductApiModel> _parseProducts(dynamic data) {
    final List list = data as List;
    return list
        .map((e) => ProductApiModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ProductApiModel>> getProductsByStore(String storeId) async {
    final response = await _apiClient.get(
      ApiEndpoints.getProductsByStore(storeId),
    );
    if (response.data['success'] == true) {
      return _parseProducts(response.data['data']);
    }
    return [];
  }

  @override
  Future<List<ProductApiModel>> getProductsByStoreAndCategory(
    String storeId,
    String categoryId,
  ) async {
    final response = await _apiClient.get(
      ApiEndpoints.getProductsByStoreAndCategory(storeId, categoryId),
    );
    if (response.data['success'] == true) {
      return _parseProducts(response.data['data']);
    }
    return [];
  }

  @override
  Future<List<ProductApiModel>> getProductsByStoreAndSubcategory(
    String storeId,
    String subcategoryId,
  ) async {
    final response = await _apiClient.get(
      ApiEndpoints.getProductsByStoreAndSubcategory(storeId, subcategoryId),
    );
    if (response.data['success'] == true) {
      return _parseProducts(response.data['data']);
    }
    return [];
  }

  @override
  Future<List<ProductApiModel>> getAllProducts({
    String? search,
    int page = 1,
    int size = 20,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.getAllProducts,
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        'page': page,
        'size': size,
      },
    );
    if (response.data['success'] == true) {
      return _parseProducts(response.data['data']);
    }
    return [];
  }

  @override
  Future<List<CategoryApiModel>> getAllCategories() async {
    final response = await _apiClient.get(ApiEndpoints.getAllCategories);
    if (response.data['success'] == true) {
      final List data = response.data['data'] as List;
      return data
          .map((e) => CategoryApiModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
