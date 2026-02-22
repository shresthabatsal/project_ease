import 'package:equatable/equatable.dart';
import 'package:project_ease/features/product/domain/entities/category_entity.dart';
import 'package:project_ease/features/product/domain/entities/product_entity.dart';

enum ProductStatus { initial, loading, loaded, error }

class ProductState extends Equatable {
  final ProductStatus status;
  final List<ProductEntity> products;
  final List<ProductEntity> storeProducts;
  final List<CategoryEntity> categories;
  final CategoryEntity? selectedCategory;
  final String searchQuery;
  final String? errorMessage;

  const ProductState({
    this.status = ProductStatus.initial,
    this.products = const [],
    this.storeProducts = const [],
    this.categories = const [],
    this.selectedCategory,
    this.searchQuery = '',
    this.errorMessage,
  });

  ProductState copyWith({
    ProductStatus? status,
    List<ProductEntity>? products,
    List<ProductEntity>? storeProducts,
    List<CategoryEntity>? categories,
    CategoryEntity? selectedCategory,
    bool clearSelectedCategory = false,
    String? searchQuery,
    String? errorMessage,
  }) {
    return ProductState(
      status: status ?? this.status,
      products: products ?? this.products,
      storeProducts: storeProducts ?? this.storeProducts,
      categories: categories ?? this.categories,
      selectedCategory: clearSelectedCategory
          ? null
          : (selectedCategory ?? this.selectedCategory),
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    products,
    storeProducts,
    categories,
    selectedCategory,
    searchQuery,
    errorMessage,
  ];
}

