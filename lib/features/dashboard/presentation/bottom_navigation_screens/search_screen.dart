import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/features/dashboard/widgets/category_card.dart';
import 'package:project_ease/features/dashboard/widgets/product_list_card.dart';
import 'package:project_ease/features/product/domain/entities/category_entity.dart';
import 'package:project_ease/features/product/presentation/state/product_state.dart';
import 'package:project_ease/features/product/presentation/view_model/product_view_model.dart';
import 'package:project_ease/features/store/presentation/view_model/store_view_model.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final storeState = ref.read(storeViewModelProvider);
      if (storeState.selectedStore != null) {
        ref
            .read(productViewModelProvider.notifier)
            .loadForStore(storeState.selectedStore!.storeId);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query, String storeId) {
    _debounce?.cancel();
    if (query.isEmpty) {
      ref.read(productViewModelProvider.notifier).clearSearch(storeId);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref
          .read(productViewModelProvider.notifier)
          .searchProducts(storeId, query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;
    final storeState = ref.watch(storeViewModelProvider);
    final productState = ref.watch(productViewModelProvider);

    // React to store changes
    ref.listen(storeViewModelProvider, (prev, next) {
      if (prev?.selectedStore?.storeId != next.selectedStore?.storeId &&
          next.selectedStore != null) {
        _searchController.clear();
        ref
            .read(productViewModelProvider.notifier)
            .loadForStore(next.selectedStore!.storeId);
      }
    });

    final selectedStoreId = storeState.selectedStore?.storeId;
    final isSearching = productState.searchQuery.isNotEmpty;
    final hasSelectedCategory = productState.selectedCategory != null;
    final showProducts = isSearching || hasSelectedCategory;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SearchBar(
              controller: _searchController,
              isTablet: isTablet,
              onChanged: (query) {
                if (selectedStoreId != null) {
                  _onSearchChanged(query, selectedStoreId);
                }
              },
              onClear: () {
                _searchController.clear();
                if (selectedStoreId != null) {
                  ref
                      .read(productViewModelProvider.notifier)
                      .clearSearch(selectedStoreId);
                }
              },
            ),
            if (selectedStoreId == null)
              const Expanded(
                child: Center(
                  child: Text(
                    'Please select a store first.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else ...[
              if (showProducts) ...[
                _SectionHeader(
                  title: isSearching
                      ? 'Results for "${productState.searchQuery}"'
                      : productState.selectedCategory?.name ?? '',
                  onBack: () {
                    _searchController.clear();
                    ref
                        .read(productViewModelProvider.notifier)
                        .clearSearch(selectedStoreId);
                  },
                  isTablet: isTablet,
                ),
              ] else
                _CategoryHeader(isTablet: isTablet),
              Expanded(
                child: productState.status == ProductStatus.loading
                    ? const Center(child: CircularProgressIndicator())
                    : productState.status == ProductStatus.error
                    ? _ErrorView(message: productState.errorMessage)
                    : showProducts
                    ? _ProductList(
                        products: productState.products,
                        isTablet: isTablet,
                      )
                    : _CategoryList(
                        categories: productState.categories,
                        selectedCategory: productState.selectedCategory,
                        storeId: selectedStoreId,
                        isTablet: isTablet,
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Search Bar

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isTablet;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.isTablet,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, isTablet ? 20 : 14, 16, 12),
      child: Container(
        height: isTablet ? 52 : 46,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          style: TextStyle(fontSize: isTablet ? 16 : 14),
          decoration: InputDecoration(
            hintText: 'Search products in this store...',
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: isTablet ? 15 : 13,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey.shade400,
              size: isTablet ? 24 : 20,
            ),
            suffixIcon: controller.text.isNotEmpty
                ? GestureDetector(
                    onTap: onClear,
                    child: Icon(
                      Icons.close,
                      color: Colors.grey.shade400,
                      size: isTablet ? 20 : 18,
                    ),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 12),
          ),
        ),
      ),
    );
  }
}

// Section Header

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final bool isTablet;

  const _SectionHeader({
    required this.title,
    required this.onBack,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            color: Colors.black87,
          ),
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isTablet ? 18 : 15,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  final bool isTablet;
  const _CategoryHeader({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 16, 10),
      child: Text(
        'Categories',
        style: TextStyle(
          fontSize: isTablet ? 20 : 16,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
    );
  }
}

// Category List

class _CategoryList extends ConsumerWidget {
  final List<CategoryEntity> categories;
  final CategoryEntity? selectedCategory;
  final String storeId;
  final bool isTablet;

  const _CategoryList({
    required this.categories,
    required this.selectedCategory,
    required this.storeId,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (categories.isEmpty) {
      return const Center(
        child: Text(
          'No categories found.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    if (isTablet) {
      // 2 column grid for tablets
      return GridView.builder(
        padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: 110,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: categories.length,
        itemBuilder: (_, i) => CategoryCard(
          category: categories[i],
          isSelected: selectedCategory?.categoryId == categories[i].categoryId,
          isTablet: true,
          onTap: () => ref
              .read(productViewModelProvider.notifier)
              .selectCategory(storeId, categories[i]),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: categories.length,
      itemBuilder: (_, i) => CategoryCard(
        category: categories[i],
        isSelected: selectedCategory?.categoryId == categories[i].categoryId,
        isTablet: false,
        onTap: () => ref
            .read(productViewModelProvider.notifier)
            .selectCategory(storeId, categories[i]),
      ),
    );
  }
}

// Product List

class _ProductList extends StatelessWidget {
  final List products;
  final bool isTablet;

  const _ProductList({required this.products, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text('No products found.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (isTablet) {
      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: 130,
          crossAxisSpacing: 10,
          mainAxisSpacing: 0,
        ),
        itemCount: products.length,
        itemBuilder: (_, i) =>
            ProductListCard(product: products[i], isTablet: true),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: products.length,
      itemBuilder: (_, i) =>
          ProductListCard(product: products[i], isTablet: false),
    );
  }
}

// Error View

class _ErrorView extends StatelessWidget {
  final String? message;
  const _ErrorView({this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 8),
            Text(
              message ?? 'Something went wrong.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
