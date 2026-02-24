import 'package:equatable/equatable.dart';
import 'package:project_ease/features/product/domain/entities/category_entity.dart';
import 'package:project_ease/features/product/domain/entities/product_entity.dart';

enum ProductStatus { initial, loading, loadingMore, loaded, error }

// Filter
class ProductFilter extends Equatable {
  final String? subcategoryId;
  final String? subcategoryName;
  final double? minPrice;
  final double? maxPrice;
  final String sortBy;
  final String sortOrder;

  const ProductFilter({
    this.subcategoryId,
    this.subcategoryName,
    this.minPrice,
    this.maxPrice,
    this.sortBy = 'createdAt',
    this.sortOrder = 'desc',
  });

  bool get hasActiveFilters =>
      subcategoryId != null || minPrice != null || maxPrice != null;

  ProductFilter copyWith({
    String? subcategoryId,
    String? subcategoryName,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? sortOrder,
    bool clearSubcategory = false,
    bool clearPriceRange = false,
  }) {
    return ProductFilter(
      subcategoryId: clearSubcategory
          ? null
          : (subcategoryId ?? this.subcategoryId),
      subcategoryName: clearSubcategory
          ? null
          : (subcategoryName ?? this.subcategoryName),
      minPrice: clearPriceRange ? null : (minPrice ?? this.minPrice),
      maxPrice: clearPriceRange ? null : (maxPrice ?? this.maxPrice),
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  ProductFilter cleared() => const ProductFilter();

  @override
  List<Object?> get props => [
    subcategoryId,
    subcategoryName,
    minPrice,
    maxPrice,
    sortBy,
    sortOrder,
  ];
}

// State

class ProductState extends Equatable {
  final ProductStatus status;
  final List<ProductEntity> products;
  final int currentPage;
  final int totalPages;
  final bool hasMore;
  final List<ProductEntity> storeProducts;
  final List<CategoryEntity> categories;
  final CategoryEntity? selectedCategory;
  final String searchQuery;
  final ProductFilter filter;
  final bool isFilterMode;

  final String? errorMessage;

  const ProductState({
    this.status = ProductStatus.initial,
    this.products = const [],
    this.currentPage = 1,
    this.totalPages = 1,
    this.hasMore = false,
    this.storeProducts = const [],
    this.categories = const [],
    this.selectedCategory,
    this.searchQuery = '',
    this.filter = const ProductFilter(),
    this.isFilterMode = false,
    this.errorMessage,
  });

  ProductState copyWith({
    ProductStatus? status,
    List<ProductEntity>? products,
    int? currentPage,
    int? totalPages,
    bool? hasMore,
    List<ProductEntity>? storeProducts,
    List<CategoryEntity>? categories,
    CategoryEntity? selectedCategory,
    bool clearSelectedCategory = false,
    String? searchQuery,
    ProductFilter? filter,
    bool? isFilterMode,
    String? errorMessage,
  }) {
    return ProductState(
      status: status ?? this.status,
      products: products ?? this.products,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasMore: hasMore ?? this.hasMore,
      storeProducts: storeProducts ?? this.storeProducts,
      categories: categories ?? this.categories,
      selectedCategory: clearSelectedCategory
          ? null
          : (selectedCategory ?? this.selectedCategory),
      searchQuery: searchQuery ?? this.searchQuery,
      filter: filter ?? this.filter,
      isFilterMode: isFilterMode ?? this.isFilterMode,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get showProducts =>
      searchQuery.isNotEmpty || selectedCategory != null || isFilterMode;

  @override
  List<Object?> get props => [
    status,
    products,
    currentPage,
    totalPages,
    hasMore,
    storeProducts,
    categories,
    selectedCategory,
    searchQuery,
    filter,
    isFilterMode,
    errorMessage,
  ];
}
