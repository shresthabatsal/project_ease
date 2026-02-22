import 'package:project_ease/features/product/data/models/product_api_model.dart';

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
  Future<List<ProductApiModel>> getAllProducts({
    String? search,
    int page,
    int size,
  });
  Future<List<CategoryApiModel>> getAllCategories();
}
