import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/features/product/domain/entities/category_entity.dart';
import 'package:project_ease/features/product/domain/usecases/get_all_categories_usecase.dart';
import 'package:project_ease/features/product/domain/usecases/get_products_by_store_category.dart';
import 'package:project_ease/features/product/domain/usecases/get_products_by_store_usecase.dart';
import 'package:project_ease/features/product/domain/usecases/search_products.dart';
import 'package:project_ease/features/product/presentation/state/product_state.dart';

final productViewModelProvider =
    NotifierProvider<ProductViewModel, ProductState>(() {
      return ProductViewModel();
    });

class ProductViewModel extends Notifier<ProductState> {
  late final GetCategoriesByStoreUsecase _getCategoriesUsecase;
  late final GetProductsByStoreCategoryUsecase _getProductsByCategoryUsecase;
  late final SearchProductsUsecase _searchProductsUsecase;
  late final GetProductsByStoreUsecase _getProductsByStoreUsecase;

  @override
  ProductState build() {
    _getCategoriesUsecase = ref.read(getCategoriesByStoreUsecaseProvider);
    _getProductsByCategoryUsecase = ref.read(
      getProductsByStoreCategoryUsecaseProvider,
    );
    _searchProductsUsecase = ref.read(searchProductsUsecaseProvider);
    _getProductsByStoreUsecase = ref.read(getProductsByStoreUsecaseProvider);
    return const ProductState();
  }

  // Call this when the store changes
  Future<void> loadForStore(String storeId) async {
    state = state.copyWith(
      status: ProductStatus.loading,
      clearSelectedCategory: true,
      searchQuery: '',
    );

    // Get store products to derive categories
    final productsResult = await _getProductsByStoreUsecase(storeId);

    await productsResult.fold(
      (failure) async => state = state.copyWith(
        status: ProductStatus.error,
        errorMessage: failure.message,
      ),
      (storeProducts) async {
        // Get categories filtered to this store
        final categoriesResult = await _getCategoriesUsecase(
          storeId,
          storeProducts,
        );

        categoriesResult.fold(
          (failure) => state = state.copyWith(
            status: ProductStatus.error,
            errorMessage: failure.message,
          ),
          (categories) => state = state.copyWith(
            status: ProductStatus.loaded,
            storeProducts: storeProducts,
            categories: categories,
            products: [],
          ),
        );
      },
    );
  }

  Future<void> selectCategory(String storeId, CategoryEntity category) async {
    state = state.copyWith(
      status: ProductStatus.loading,
      selectedCategory: category,
      searchQuery: '',
    );
    final result = await _getProductsByCategoryUsecase(
      GetProductsByStoreCategoryUsecaseParams(
        storeId: storeId,
        categoryId: category.categoryId,
      ),
    );
    result.fold(
      (failure) => state = state.copyWith(
        status: ProductStatus.error,
        errorMessage: failure.message,
      ),
      (products) => state = state.copyWith(
        status: ProductStatus.loaded,
        products: products,
      ),
    );
  }

  Future<void> searchProducts(String storeId, String query) async {
    state = state.copyWith(
      searchQuery: query,
      status: ProductStatus.loading,
      clearSelectedCategory: true,
    );
    final result = await _searchProductsUsecase(
      SearchProductsUsecaseParams(storeId: storeId, search: query),
    );
    result.fold(
      (failure) => state = state.copyWith(
        status: ProductStatus.error,
        errorMessage: failure.message,
      ),
      (products) => state = state.copyWith(
        status: ProductStatus.loaded,
        products: products,
      ),
    );
  }

  void clearSearch(String storeId) {
    state = state.copyWith(
      searchQuery: '',
      products: [],
      clearSelectedCategory: true,
      status: ProductStatus.loaded,
    );
  }
}
