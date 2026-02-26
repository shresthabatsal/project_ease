import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/api/api_client.dart';
import 'package:project_ease/core/api/api_endpoints.dart';
import 'package:project_ease/features/cart/data/models/cart_api_model.dart';

final cartRemoteDatasourceProvider = Provider<CartRemoteDatasource>(
  (ref) => CartRemoteDatasource(apiClient: ref.read(apiClientProvider)),
);

class CartRemoteDatasource {
  final ApiClient _apiClient;
  CartRemoteDatasource({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<CartItemApiModel>> getCart() async {
    final response = await _apiClient.get(ApiEndpoints.getCart);
    final List items = response.data['data']['items'] as List? ?? [];
    return items
        .map((e) => CartItemApiModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CartItemApiModel> addToCart({
    required String productId,
    required int quantity,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.addToCart,
      data: {'productId': productId, 'quantity': quantity},
    );
    return CartItemApiModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  Future<CartItemApiModel> updateCartItem({
    required String cartItemId,
    required int quantity,
  }) async {
    final response = await _apiClient.put(
      ApiEndpoints.updateCartItem(cartItemId),
      data: {'quantity': quantity},
    );
    return CartItemApiModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  Future<void> removeFromCart(String cartItemId) async {
    await _apiClient.delete(ApiEndpoints.removeCartItem(cartItemId));
  }

  Future<void> clearCart() async {
    await _apiClient.delete(ApiEndpoints.clearCart);
  }
}
