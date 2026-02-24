import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/apps/theme/app_colors.dart';
import 'package:project_ease/features/dashboard/widgets/category_card.dart';
import 'package:project_ease/features/dashboard/widgets/product_list_card.dart';
import 'package:project_ease/features/product/domain/entities/category_entity.dart';
import 'package:project_ease/features/product/domain/entities/product_entity.dart';
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
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final storeState = ref.read(storeViewModelProvider);
      final productState = ref.read(productViewModelProvider);
      if (storeState.selectedStore != null &&
          productState.status == ProductStatus.initial) {
        ref
            .read(productViewModelProvider.notifier)
            .loadForStore(storeState.selectedStore!.storeId);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final storeId = ref.read(storeViewModelProvider).selectedStore?.storeId;
      if (storeId != null) {
        ref.read(productViewModelProvider.notifier).loadNextPage(storeId);
      }
    }
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

  void _goBack(String storeId) {
    _searchController.clear();
    ref.read(productViewModelProvider.notifier).clearSearch(storeId);
  }

  void _showFilterSheet(BuildContext context, String storeId) {
    final productState = ref.read(productViewModelProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(
        storeId: storeId,
        storeProducts: productState.storeProducts,
        selectedCategory: productState.selectedCategory,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;
    final storeState = ref.watch(storeViewModelProvider);
    final productState = ref.watch(productViewModelProvider);

    // Store change, reload
    ref.listen(storeViewModelProvider, (prev, next) {
      if (prev?.selectedStore?.storeId != next.selectedStore?.storeId &&
          next.selectedStore != null) {
        _searchController.clear();
        ref
            .read(productViewModelProvider.notifier)
            .loadForStore(next.selectedStore!.storeId);
      }
    });

    // Category selected from home screen, fetch its products
    ref.listen(productViewModelProvider, (prev, next) {
      if (prev?.selectedCategory == null &&
          next.selectedCategory != null &&
          next.products.isEmpty &&
          !next.isFilterMode) {
        final storeId = storeState.selectedStore?.storeId;
        if (storeId != null) {
          ref
              .read(productViewModelProvider.notifier)
              .selectCategory(storeId, next.selectedCategory!);
        }
      }
    });

    final selectedStoreId = storeState.selectedStore?.storeId;
    final showProducts = productState.showProducts;

    // Title
    String headerTitle = '';
    if (productState.selectedCategory != null) {
      headerTitle = productState.selectedCategory!.name;
    } else if (productState.searchQuery.isNotEmpty) {
      headerTitle = 'Results for "${productState.searchQuery}"';
    } else if (productState.isFilterMode) {
      headerTitle = 'Filtered Products';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (selectedStoreId == null)
            // No store
            ...[
              _PlainSearchBar(
                controller: _searchController,
                isTablet: isTablet,
                onChanged: (_) {},
                onClear: () {},
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    'Please select a store first.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ] else if (!showProducts) ...[
              _PlainSearchBar(
                controller: _searchController,
                isTablet: isTablet,
                onChanged: (q) => _onSearchChanged(q, selectedStoreId),
                onClear: () {
                  _searchController.clear();
                  ref
                      .read(productViewModelProvider.notifier)
                      .clearSearch(selectedStoreId);
                },
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 16, 10),
                child: Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: isTablet ? 20 : 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
              Expanded(
                child: productState.status == ProductStatus.loading
                    ? const Center(child: CircularProgressIndicator())
                    : productState.status == ProductStatus.error
                    ? _ErrorView(message: productState.errorMessage)
                    : _CategoryView(
                        categories: productState.categories,
                        storeId: selectedStoreId,
                        isTablet: isTablet,
                      ),
              ),
            ] else ...[
              // Back button and title
              _ProductModeHeader(
                title: headerTitle,
                isTablet: isTablet,
                onBack: () => _goBack(selectedStoreId),
              ),
              // Search bar with filter button
              _SearchBarWithFilter(
                controller: _searchController,
                isTablet: isTablet,
                hasActiveFilter: productState.filter.hasActiveFilters,
                onChanged: (q) => _onSearchChanged(q, selectedStoreId),
                onClear: () {
                  _searchController.clear();
                  ref
                      .read(productViewModelProvider.notifier)
                      .clearSearch(selectedStoreId);
                },
                onFilterTap: () => _showFilterSheet(context, selectedStoreId),
              ),
              // Content: product list
              Expanded(
                child: productState.status == ProductStatus.loading
                    ? const Center(child: CircularProgressIndicator())
                    : productState.status == ProductStatus.error
                    ? _ErrorView(message: productState.errorMessage)
                    : _ProductList(
                        products: productState.products,
                        isLoadingMore:
                            productState.status == ProductStatus.loadingMore,
                        scrollController: _scrollController,
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

class _PlainSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isTablet;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _PlainSearchBar({
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
            hintText: 'Search products...',
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

class _ProductModeHeader extends StatelessWidget {
  final String title;
  final bool isTablet;
  final VoidCallback onBack;

  const _ProductModeHeader({
    required this.title,
    required this.isTablet,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(4, isTablet ? 16 : 10, 16, 0),
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
                fontSize: isTablet ? 19 : 16,
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

// Search Bar and Filter Button

class _SearchBarWithFilter extends StatelessWidget {
  final TextEditingController controller;
  final bool isTablet;
  final bool hasActiveFilter;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final VoidCallback onFilterTap;

  const _SearchBarWithFilter({
    required this.controller,
    required this.isTablet,
    required this.hasActiveFilter,
    required this.onChanged,
    required this.onClear,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          Expanded(
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
                  hintText: 'Search products...',
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
                  contentPadding: EdgeInsets.symmetric(
                    vertical: isTablet ? 16 : 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Filter button
          GestureDetector(
            onTap: onFilterTap,
            child: Container(
              width: isTablet ? 52 : 46,
              height: isTablet ? 52 : 46,
              decoration: BoxDecoration(
                color: hasActiveFilter ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.tune_rounded,
                    color: hasActiveFilter
                        ? Colors.white
                        : Colors.grey.shade600,
                    size: isTablet ? 24 : 20,
                  ),
                  if (hasActiveFilter)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Category View

class _CategoryView extends ConsumerWidget {
  final List<CategoryEntity> categories;
  final String storeId;
  final bool isTablet;

  const _CategoryView({
    required this.categories,
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
      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: 110,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: categories.length,
        itemBuilder: (_, i) => CategoryCard(
          category: categories[i],
          isSelected: false,
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
        isSelected: false,
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
  final List<ProductEntity> products;
  final bool isLoadingMore;
  final ScrollController scrollController;
  final bool isTablet;

  const _ProductList({
    required this.products,
    required this.isLoadingMore,
    required this.scrollController,
    required this.isTablet,
  });

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

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: products.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (_, i) {
        if (i == products.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        return ProductListCard(product: products[i], isTablet: isTablet);
      },
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

// Filter Sheet
class _FilterSheet extends ConsumerStatefulWidget {
  final String storeId;
  final List<ProductEntity> storeProducts;
  final CategoryEntity? selectedCategory;

  const _FilterSheet({
    required this.storeId,
    required this.storeProducts,
    this.selectedCategory,
  });

  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  late ProductFilter _filter;
  late RangeValues _priceRange;
  late double _minBound;
  late double _maxBound;

  late final List<ProductEntity> _snapshot;
  late final List<_SubcategoryOption> _subcategories;

  @override
  void initState() {
    super.initState();
    final productState = ref.read(productViewModelProvider);
    _filter = productState.filter;

    // Scope to current category's products only
    _snapshot = List.unmodifiable(
      widget.selectedCategory != null
          ? widget.storeProducts
                .where(
                  (p) => p.categoryId == widget.selectedCategory!.categoryId,
                )
                .toList()
          : widget.storeProducts,
    );

    _subcategories = _buildSubcategories(_snapshot);

    if (_snapshot.isEmpty) {
      _minBound = 0;
      _maxBound = 10000;
    } else {
      final prices = _snapshot.map((p) => p.price);
      final rawMin = prices.reduce((a, b) => a < b ? a : b);
      final rawMax = prices.reduce((a, b) => a > b ? a : b);
      _minBound = (rawMin / 100).floor() * 100.0;
      _maxBound = (rawMax / 100).ceil() * 100.0;
      if (_maxBound <= _minBound) _maxBound = _minBound + 100;
    }

    _priceRange = RangeValues(
      (_filter.minPrice ?? _minBound).clamp(_minBound, _maxBound),
      (_filter.maxPrice ?? _maxBound).clamp(_minBound, _maxBound),
    );
  }

  List<_SubcategoryOption> _buildSubcategories(List<ProductEntity> products) {
    final seen = <String>{};
    final result = <_SubcategoryOption>[];
    for (final p in products) {
      if (p.subcategoryId != null &&
          p.subcategoryName != null &&
          seen.add(p.subcategoryId!)) {
        result.add(
          _SubcategoryOption(id: p.subcategoryId!, name: p.subcategoryName!),
        );
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;
    final divisions = ((_maxBound - _minBound) / 100).round().clamp(1, 500);

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (ctx, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
              child: Row(
                children: [
                  Text(
                    'Filter & Sort',
                    style: TextStyle(
                      fontSize: isTablet ? 20 : 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => setState(() {
                      _filter = const ProductFilter();
                      _priceRange = RangeValues(_minBound, _maxBound);
                    }),
                    child: Text(
                      'Reset',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close),
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  // Sort
                  const _FilterSectionTitle(title: 'Sort By'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _FilterChip(
                        label: 'Newest',
                        selected:
                            _filter.sortBy == 'createdAt' &&
                            _filter.sortOrder == 'desc',
                        onTap: () => setState(
                          () => _filter = _filter.copyWith(
                            sortBy: 'createdAt',
                            sortOrder: 'desc',
                          ),
                        ),
                      ),
                      _FilterChip(
                        label: 'Oldest',
                        selected:
                            _filter.sortBy == 'createdAt' &&
                            _filter.sortOrder == 'asc',
                        onTap: () => setState(
                          () => _filter = _filter.copyWith(
                            sortBy: 'createdAt',
                            sortOrder: 'asc',
                          ),
                        ),
                      ),
                      _FilterChip(
                        label: 'Price: Low → High',
                        selected:
                            _filter.sortBy == 'price' &&
                            _filter.sortOrder == 'asc',
                        onTap: () => setState(
                          () => _filter = _filter.copyWith(
                            sortBy: 'price',
                            sortOrder: 'asc',
                          ),
                        ),
                      ),
                      _FilterChip(
                        label: 'Price: High → Low',
                        selected:
                            _filter.sortBy == 'price' &&
                            _filter.sortOrder == 'desc',
                        onTap: () => setState(
                          () => _filter = _filter.copyWith(
                            sortBy: 'price',
                            sortOrder: 'desc',
                          ),
                        ),
                      ),
                      _FilterChip(
                        label: 'Name A–Z',
                        selected:
                            _filter.sortBy == 'name' &&
                            _filter.sortOrder == 'asc',
                        onTap: () => setState(
                          () => _filter = _filter.copyWith(
                            sortBy: 'name',
                            sortOrder: 'asc',
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Price range
                  const _FilterSectionTitle(title: 'Price Range'),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('NPR ${_priceRange.start.toInt()}'),
                      Text(
                        _priceRange.end >= _maxBound
                            ? 'NPR ${_maxBound.toInt()}+'
                            : 'NPR ${_priceRange.end.toInt()}',
                      ),
                    ],
                  ),
                  RangeSlider(
                    values: _priceRange,
                    min: _minBound,
                    max: _maxBound,
                    divisions: divisions,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.primary.withOpacity(0.2),
                    onChanged: (v) => setState(() {
                      _priceRange = v;
                      _filter = _filter.copyWith(
                        minPrice: v.start > _minBound ? v.start : null,
                        maxPrice: v.end < _maxBound ? v.end : null,
                        clearPriceRange:
                            v.start <= _minBound && v.end >= _maxBound,
                      );
                    }),
                  ),

                  // Subcategories
                  if (_subcategories.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const _FilterSectionTitle(title: 'Subcategory'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _FilterChip(
                          label: 'All',
                          selected: _filter.subcategoryId == null,
                          onTap: () => setState(
                            () => _filter = _filter.copyWith(
                              clearSubcategory: true,
                            ),
                          ),
                        ),
                        ..._subcategories.map(
                          (sub) => _FilterChip(
                            label: sub.name,
                            selected: _filter.subcategoryId == sub.id,
                            onTap: () => setState(
                              () => _filter = _filter.copyWith(
                                subcategoryId: sub.id,
                                subcategoryName: sub.name,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                MediaQuery.of(context).padding.bottom + 12,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    ref
                        .read(productViewModelProvider.notifier)
                        .applyFilter(widget.storeId, _filter);
                  },
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubcategoryOption {
  final String id;
  final String name;
  const _SubcategoryOption({required this.id, required this.name});
}

class _FilterSectionTitle extends StatelessWidget {
  final String title;
  const _FilterSectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : AppColors.primary.withOpacity(0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.primary.withOpacity(0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? Colors.white : AppColors.primary,
          ),
        ),
      ),
    );
  }
}
