import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/api/api_client.dart';
import 'package:project_ease/core/api/api_endpoints.dart';
import 'package:project_ease/features/product/data/models/product_api_model.dart';

class PaginatedProductsRaw {
  final List<ProductApiModel> products;
  final int page;
  final int totalPages;
  final int total;
  const PaginatedProductsRaw({
    required this.products,
    required this.page,
    required this.totalPages,
    required this.total,
  });
}

abstract interface class IProductRemoteDatasource {
  Future<List<ProductApiModel>> getProductsByStore(String storeId);
  Future<List<ProductApiModel>> getProductsByStoreAndCategory(
    String storeId,
    String categoryId,
  );
  Future<List<ProductApiModel>> getProductsByStoreAndSubcategory(
    String storeId,
    String subcategoryId,
  );
  Future<PaginatedProductsRaw> getAllProducts({
    String? search,
    int page,
    int size,
    String sortBy,
    String sortOrder,
  });
  Future<List<CategoryApiModel>> getAllCategories();
}

final productRemoteDatasourceProvider = Provider<IProductRemoteDatasource>(
  (ref) => ProductRemoteDatasource(apiClient: ref.read(apiClientProvider)),
);

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
  Future<PaginatedProductsRaw> getAllProducts({
    String? search,
    int page = 1,
    int size = 10,
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.getAllProducts,
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        'page': page,
        'size': size,
        'sortBy': sortBy,
        'sortOrder': sortOrder,
      },
    );
    if (response.data['success'] == true) {
      final pagination =
          response.data['pagination'] as Map<String, dynamic>? ?? {};
      return PaginatedProductsRaw(
        products: _parseProducts(response.data['data']),
        page: pagination['page'] ?? page,
        totalPages: pagination['totalPages'] ?? 1,
        total: pagination['total'] ?? 0,
      );
    }
    return PaginatedProductsRaw(products: [], page: 1, totalPages: 1, total: 0);
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
