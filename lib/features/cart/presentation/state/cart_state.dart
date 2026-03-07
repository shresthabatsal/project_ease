import 'package:equatable/equatable.dart';
import 'package:project_ease/features/cart/domain/entities/cart_entity.dart';

enum CartStatus { initial, loading, loaded, error }

class CartState extends Equatable {
  final CartStatus status;
  final List<CartItemEntity> items;
  final String? errorMessage;

  const CartState({
    this.status = CartStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  double get totalAmount => items.fold(0, (s, i) => s + i.subtotal);
  int get totalItems => items.fold(0, (s, i) => s + i.quantity);
  bool get isEmpty => items.isEmpty;

  CartState copyWith({
    CartStatus? status,
    List<CartItemEntity>? items,
    String? errorMessage,
  }) => CartState(
    status: status ?? this.status,
    items: items ?? this.items,
    errorMessage: errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => [status, items, errorMessage];
}
