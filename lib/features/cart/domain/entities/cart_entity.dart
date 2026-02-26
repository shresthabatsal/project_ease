import 'package:equatable/equatable.dart';
import 'package:project_ease/features/product/domain/entities/product_entity.dart';

class CartItemEntity extends Equatable {
  final String?
  cartItemId;
  final ProductEntity product;
  final int quantity;

  const CartItemEntity({
    this.cartItemId,
    required this.product,
    required this.quantity,
  });

  double get subtotal => product.price * quantity;

  CartItemEntity copyWith({int? quantity}) => CartItemEntity(
    cartItemId: cartItemId,
    product: product,
    quantity: quantity ?? this.quantity,
  );

  @override
  List<Object?> get props => [cartItemId, product.productId, quantity];
}
