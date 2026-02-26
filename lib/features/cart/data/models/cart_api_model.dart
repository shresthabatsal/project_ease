import 'package:project_ease/features/cart/domain/entities/cart_entity.dart';
import 'package:project_ease/features/product/data/models/product_api_model.dart';

class CartItemApiModel {
  final String id;
  final ProductApiModel product;
  final int quantity;

  CartItemApiModel({
    required this.id,
    required this.product,
    required this.quantity,
  });

  factory CartItemApiModel.fromJson(Map<String, dynamic> json) {
    final productRaw = json['productId'];
    return CartItemApiModel(
      id: json['_id'] ?? '',
      product: ProductApiModel.fromJson(productRaw as Map<String, dynamic>),
      quantity: json['quantity'] ?? 1,
    );
  }

  CartItemEntity toEntity() => CartItemEntity(
    cartItemId: id,
    product: product.toEntity(),
    quantity: quantity,
  );
}
