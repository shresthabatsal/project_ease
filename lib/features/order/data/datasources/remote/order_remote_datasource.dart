import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/api/api_client.dart';
import 'package:project_ease/core/api/api_endpoints.dart';
import 'package:project_ease/features/order/data/models/order_api_model.dart';
import 'package:project_ease/features/order/data/models/payment_api_model.dart';

final orderRemoteDatasourceProvider = Provider<OrderRemoteDatasource>(
  (ref) => OrderRemoteDatasource(apiClient: ref.read(apiClientProvider)),
);

class OrderRemoteDatasource {
  final ApiClient _apiClient;
  OrderRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  OrderApiModel _parseOrder(dynamic data) =>
      OrderApiModel.fromJson(data as Map<String, dynamic>);

  Future<OrderApiModel> createOrder({
    required String storeId,
    required String pickupDate,
    required String pickupTime,
    String? notes,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.createOrder,
      data: {
        'storeId': storeId,
        'pickupDate': pickupDate,
        'pickupTime': pickupTime,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );
    return _parseOrder(response.data['data']);
  }

  Future<OrderApiModel> buyNow({
    required String productId,
    required int quantity,
    required String storeId,
    required String pickupDate,
    required String pickupTime,
    String? notes,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.buyNow,
      data: {
        'productId': productId,
        'quantity': quantity,
        'storeId': storeId,
        'pickupDate': pickupDate,
        'pickupTime': pickupTime,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );
    return _parseOrder(response.data['data']);
  }

  Future<List<OrderApiModel>> getUserOrders() async {
    final response = await _apiClient.get(ApiEndpoints.getUserOrders);
    final List data = response.data['data'] as List;
    return data.map((e) => _parseOrder(e)).toList();
  }

  Future<OrderApiModel> getOrder(String orderId) async {
    final response = await _apiClient.get(ApiEndpoints.getOrderById(orderId));
    return _parseOrder(response.data['data']);
  }

  Future<OrderApiModel> cancelOrder(String orderId, String? reason) async {
    final response = await _apiClient.post(
      ApiEndpoints.cancelOrder(orderId),
      data: {if (reason != null) 'reason': reason},
    );
    return _parseOrder(response.data['data']);
  }

  Future<PaymentApiModel?> getOrderPayment(String orderId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.getOrderPayment(orderId),
      );
      final data = response.data['data'];
      if (data == null) return null;
      return PaymentApiModel.fromJson(data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> submitReceipt({
    required String orderId,
    required String receiptImagePath,
    String? paymentMethod,
    String? notes,
  }) async {
    final formData = FormData.fromMap({
      'orderId': orderId,
      'receiptImage': await MultipartFile.fromFile(receiptImagePath),
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    });
    await _apiClient.post(ApiEndpoints.submitReceipt, data: formData);
  }
}
