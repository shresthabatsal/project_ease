import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String productId;
  final String name;
  final String? description;
  final double price;
  final String? productImage;
  final String? storeId;
  final String? storeName;
  final String? categoryId;
  final String? categoryName;
  final String? subcategoryId;
  final String? subcategoryName;
  final int? stock;

  const ProductEntity({
    required this.productId,
    required this.name,
    this.description,
    required this.price,
    this.productImage,
    this.storeId,
    this.storeName,
    this.categoryId,
    this.categoryName,
    this.subcategoryId,
    this.subcategoryName,
    this.stock,
  });

  @override
  List<Object?> get props => [
    productId,
    name,
    description,
    price,
    productImage,
    storeId,
    storeName,
    categoryId,
    categoryName,
    subcategoryId,
    subcategoryName,
    stock,
  ];
}
