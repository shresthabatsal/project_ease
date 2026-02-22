import 'package:project_ease/features/product/domain/entities/category_entity.dart';
import 'package:project_ease/features/product/domain/entities/product_entity.dart';

class CategoryApiModel {
  final String id;
  final String name;
  final String? image;
  final String? description;

  CategoryApiModel({
    required this.id,
    required this.name,
    this.image,
    this.description,
  });

  factory CategoryApiModel.fromJson(Map<String, dynamic> json) {
    return CategoryApiModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'],
      description: json['description'],
    );
  }

  CategoryEntity toEntity() {
    return CategoryEntity(
      categoryId: id,
      name: name,
      image: image,
      description: description,
    );
  }
}

class ProductApiModel {
  final String id;
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

  ProductApiModel({
    required this.id,
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

  factory ProductApiModel.fromJson(Map<String, dynamic> json) {
    final storeRaw = json['storeId'];
    final categoryRaw = json['categoryId'];
    final subcategoryRaw = json['subcategoryId'];

    return ProductApiModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      price: (json['price'] ?? 0).toDouble(),
      productImage: json['productImage'],
      storeId: storeRaw is Map ? storeRaw['_id'] : storeRaw,
      storeName: storeRaw is Map ? storeRaw['name'] : null,
      categoryId: categoryRaw is Map ? categoryRaw['_id'] : categoryRaw,
      categoryName: categoryRaw is Map ? categoryRaw['name'] : null,
      subcategoryId: subcategoryRaw is Map
          ? subcategoryRaw['_id']
          : subcategoryRaw,
      subcategoryName: subcategoryRaw is Map ? subcategoryRaw['name'] : null,
      stock: json['stock'],
    );
  }

  ProductEntity toEntity() {
    return ProductEntity(
      productId: id,
      name: name,
      description: description,
      price: price,
      productImage: productImage,
      storeId: storeId,
      storeName: storeName,
      categoryId: categoryId,
      categoryName: categoryName,
      subcategoryId: subcategoryId,
      subcategoryName: subcategoryName,
      stock: stock,
    );
  }
}
