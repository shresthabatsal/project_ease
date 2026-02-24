import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/features/product/domain/entities/category_entity.dart';
import 'package:project_ease/features/product/domain/usecases/get_categories_by_store_usecase.dart';
import 'package:project_ease/features/product/domain/usecases/get_products_by_store_category.dart';
import 'package:project_ease/features/product/domain/usecases/get_products_by_store_usecase.dart';
import 'package:project_ease/features/product/domain/usecases/search_products.dart';
import 'package:project_ease/features/product/presentation/state/product_state.dart';

final productViewModelProvider =
    NotifierProvider<ProductViewModel, ProductState>(() => ProductViewModel());

class ProductViewModel extends Notifier<ProductState> {
  late final GetCategoriesByStoreUsecase _getCategoriesUsecase;
  late final GetProductsByStoreCategoryUsecase _getProductsByCategoryUsecase;
  late final SearchProductsUsecase _searchProductsUsecase;
  late final GetProductsByStoreUsecase _getProductsByStoreUsecase;

  static const int _pageSize = 10;

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

  // Load Store

  Future<void> loadForStore(String storeId) async {
    state = state.copyWith(
      status: ProductStatus.loading,
      clearSelectedCategory: true,
      searchQuery: '',
      filter: const ProductFilter(),
      isFilterMode: false,
      products: [],
      currentPage: 1,
      hasMore: false,
    );

    final productsResult = await _getProductsByStoreUsecase(storeId);

    await productsResult.fold(
      (failure) async => state = state.copyWith(
        status: ProductStatus.error,
        errorMessage: failure.message,
      ),
      (storeProducts) async {
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

  // Select category

  Future<void> selectCategory(String storeId, CategoryEntity category) async {
    state = state.copyWith(
      status: ProductStatus.loading,
      selectedCategory: category,
      searchQuery: '',
      filter: const ProductFilter(),
      isFilterMode: false,
      products: [],
      currentPage: 1,
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
        hasMore: false,
      ),
    );
  }

  // Navigate to category from home

  void navigateToCategory(CategoryEntity category) {
    state = state.copyWith(
      selectedCategory: category,
      searchQuery: '',
      filter: const ProductFilter(),
      isFilterMode: false,
      products: [],
    );
  }

  // Search

  Future<void> searchProducts(
    String storeId,
    String query, {
    ProductFilter? filter,
    bool resetPage = true,
  }) async {
    final activeFilter = filter ?? state.filter;
    final page = resetPage ? 1 : state.currentPage + 1;

    state = state.copyWith(
      searchQuery: query,
      filter: activeFilter,
      status: resetPage ? ProductStatus.loading : ProductStatus.loadingMore,
      clearSelectedCategory: true,
      isFilterMode: false,
      products: resetPage ? [] : state.products,
      currentPage: page,
    );

    final result = await _searchProductsUsecase(
      SearchProductsUsecaseParams(
        storeId: storeId,
        search: query,
        page: page,
        size: _pageSize,
        subcategoryId: activeFilter.subcategoryId,
        minPrice: activeFilter.minPrice,
        maxPrice: activeFilter.maxPrice,
        sortBy: activeFilter.sortBy,
        sortOrder: activeFilter.sortOrder,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: ProductStatus.error,
        errorMessage: failure.message,
      ),
      (data) {
        final allProducts = resetPage
            ? data.products
            : [...state.products, ...data.products];
        state = state.copyWith(
          status: ProductStatus.loaded,
          products: allProducts,
          currentPage: data.page,
          totalPages: data.totalPages,
          hasMore: data.page < data.totalPages,
        );
      },
    );
  }

  // Apply filter

  Future<void> applyFilter(String storeId, ProductFilter filter) async {
    if (state.selectedCategory != null) {
      state = state.copyWith(
        filter: filter,
        isFilterMode: true,
        status: ProductStatus.loading,
      );

      final result = await _getProductsByCategoryUsecase(
        GetProductsByStoreCategoryUsecaseParams(
          storeId: storeId,
          categoryId: state.selectedCategory!.categoryId,
        ),
      );

      result.fold(
        (failure) => state = state.copyWith(
          status: ProductStatus.error,
          errorMessage: failure.message,
          isFilterMode: false,
        ),
        (products) {
          var filtered = products;

          if (filter.subcategoryId != null) {
            filtered = filtered
                .where((p) => p.subcategoryId == filter.subcategoryId)
                .toList();
          }
          if (filter.minPrice != null) {
            filtered = filtered
                .where((p) => p.price >= filter.minPrice!)
                .toList();
          }
          if (filter.maxPrice != null) {
            filtered = filtered
                .where((p) => p.price <= filter.maxPrice!)
                .toList();
          }
          // Sort
          filtered = List.from(filtered)
            ..sort((a, b) {
              int cmp;
              if (filter.sortBy == 'price') {
                cmp = a.price.compareTo(b.price);
              } else if (filter.sortBy == 'name') {
                cmp = a.name.compareTo(b.name);
              } else {
                cmp = 0;
              }
              return filter.sortOrder == 'asc' ? cmp : -cmp;
            });

          state = state.copyWith(
            status: ProductStatus.loaded,
            products: filtered,
            hasMore: false,
          );
        },
      );
      return;
    }

    // Search mode
    state = state.copyWith(
      filter: filter,
      isFilterMode: true,
      status: ProductStatus.loading,
      products: [],
      currentPage: 1,
      hasMore: false,
    );

    final result = await _searchProductsUsecase(
      SearchProductsUsecaseParams(
        storeId: storeId,
        search: state.searchQuery,
        page: 1,
        size: _pageSize,
        subcategoryId: filter.subcategoryId,
        minPrice: filter.minPrice,
        maxPrice: filter.maxPrice,
        sortBy: filter.sortBy,
        sortOrder: filter.sortOrder,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: ProductStatus.error,
        errorMessage: failure.message,
        isFilterMode: false,
      ),
      (data) => state = state.copyWith(
        status: ProductStatus.loaded,
        products: data.products,
        currentPage: data.page,
        totalPages: data.totalPages,
        hasMore: data.page < data.totalPages,
      ),
    );
  }

  Future<void> loadNextPage(String storeId) async {
    if (!state.hasMore || state.status == ProductStatus.loadingMore) return;
    if (state.isFilterMode) {
      // paginate filtered results
      final page = state.currentPage + 1;
      state = state.copyWith(
        status: ProductStatus.loadingMore,
        currentPage: page,
      );
      final result = await _searchProductsUsecase(
        SearchProductsUsecaseParams(
          storeId: storeId,
          search: state.searchQuery,
          page: page,
          size: _pageSize,
          subcategoryId: state.filter.subcategoryId,
          minPrice: state.filter.minPrice,
          maxPrice: state.filter.maxPrice,
          sortBy: state.filter.sortBy,
          sortOrder: state.filter.sortOrder,
        ),
      );
      result.fold(
        (failure) => state = state.copyWith(status: ProductStatus.loaded),
        (data) => state = state.copyWith(
          status: ProductStatus.loaded,
          products: [...state.products, ...data.products],
          currentPage: data.page,
          hasMore: data.page < data.totalPages,
        ),
      );
    } else {
      await searchProducts(
        storeId,
        state.searchQuery,
        filter: state.filter,
        resetPage: false,
      );
    }
  }

  void clearFilter(String storeId) {
    state = state.copyWith(
      filter: const ProductFilter(),
      isFilterMode: false,
      products: [],
      currentPage: 1,
      hasMore: false,
      status: ProductStatus.loaded,
    );
  }

  void clearSearch(String storeId) {
    state = state.copyWith(
      searchQuery: '',
      products: [],
      clearSelectedCategory: true,
      filter: const ProductFilter(),
      isFilterMode: false,
      status: ProductStatus.loaded,
      currentPage: 1,
      hasMore: false,
    );
  }
}
