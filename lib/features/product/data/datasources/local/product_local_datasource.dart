import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:project_ease/core/constants/hive_table_constant.dart';
import 'package:project_ease/features/product/data/models/category_hive_model.dart';
import 'package:project_ease/features/product/data/models/product_api_model.dart';
import 'package:project_ease/features/product/data/models/product_hive_model.dart';

final productLocalDatasourceProvider = Provider<ProductLocalDatasource>(
  (ref) => ProductLocalDatasource(),
);

class ProductLocalDatasource {
  Box<CategoryHiveModel> get _categoryBox =>
      Hive.box<CategoryHiveModel>(HiveTableConstant.categoriesTable);

  Future<Box<ProductHiveModel>> _productBox(String storeId) =>
      Hive.openBox<ProductHiveModel>(
        HiveTableConstant.productsBoxForStore(storeId),
      );

  // Save
  Future<void> saveCategories(List<CategoryApiModel> models) async {
    await _categoryBox.clear();
    await _categoryBox.putAll({
      for (final m in models)
        m.id: CategoryHiveModel(
          id: m.id,
          name: m.name,
          image: m.image,
          description: m.description,
        ),
    });
    debugPrint('[Cache] Saved ${_categoryBox.length} categories.');
  }

  Future<void> saveProductsForStore(
    String storeId,
    List<ProductApiModel> models,
  ) async {
    final box = await _productBox(storeId);
    await box.clear();
    await box.putAll({
      for (final m in models)
        m.id: ProductHiveModel(
          id: m.id,
          name: m.name,
          description: m.description,
          price: m.price,
          productImage: m.productImage,
          storeId: m.storeId,
          storeName: m.storeName,
          categoryId: m.categoryId,
          categoryName: m.categoryName,
          subcategoryId: m.subcategoryId,
          subcategoryName: m.subcategoryName,
          stock: m.stock,
        ),
    });
    debugPrint('[Cache] Saved ${box.length} products for store: $storeId');
  }

  // Read
  List<CategoryApiModel> getCategories() {
    final categories = _categoryBox.values
        .map(
          (h) => CategoryApiModel(
            id: h.id,
            name: h.name,
            image: h.image,
            description: h.description,
          ),
        )
        .toList();
    debugPrint('[Cache] Read ${categories.length} categories from cache.');
    return categories;
  }

  Future<List<ProductApiModel>> getProductsForStore(String storeId) async {
    final box = await _productBox(storeId);
    final products = box.values
        .map(
          (h) => ProductApiModel(
            id: h.id,
            name: h.name,
            description: h.description,
            price: h.price,
            productImage: h.productImage,
            storeId: h.storeId,
            storeName: h.storeName,
            categoryId: h.categoryId,
            categoryName: h.categoryName,
            subcategoryId: h.subcategoryId,
            subcategoryName: h.subcategoryName,
            stock: h.stock,
          ),
        )
        .toList();
    debugPrint('[Cache] Read ${products.length} products for store: $storeId');
    return products;
  }

  bool hasCategories() {
    final has = _categoryBox.isNotEmpty;
    debugPrint('[Cache] hasCategories: $has (count: ${_categoryBox.length})');
    return has;
  }

  Future<bool> hasProductsForStore(String storeId) async {
    final box = await _productBox(storeId);
    final has = box.isNotEmpty;
    debugPrint(
      '[Cache] hasProductsForStore($storeId): $has (count: ${box.length})',
    );
    return has;
  }
}
