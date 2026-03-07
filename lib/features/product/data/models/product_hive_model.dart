import 'package:hive/hive.dart';

part 'product_hive_model.g.dart';

@HiveType(typeId: 10)
class ProductHiveModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String? description;
  @HiveField(3)
  final double price;
  @HiveField(4)
  final String? productImage;
  @HiveField(5)
  final String? storeId;
  @HiveField(6)
  final String? storeName;
  @HiveField(7)
  final String? categoryId;
  @HiveField(8)
  final String? categoryName;
  @HiveField(9)
  final String? subcategoryId;
  @HiveField(10)
  final String? subcategoryName;
  @HiveField(11)
  final int? stock;

  ProductHiveModel({
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
}
