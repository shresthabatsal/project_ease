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
import 'package:shared_preferences/shared_preferences.dart';

class _RecentSearches {
  static const _key = 'recent_searches';
  static const _max = 8;

  static Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  static Future<void> add(String query) async {
    if (query.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    list.remove(query);
    list.insert(0, query);
    if (list.length > _max) list.removeLast();
    await prefs.setStringList(_key, list);
  }

  static Future<void> remove(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    list.remove(query);
    await prefs.setStringList(_key, list);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final ScrollController _scrollController = ScrollController();

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
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
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

  void _goBack(String storeId) {
    ref.read(productViewModelProvider.notifier).clearSearch(storeId);
  }

  void _showFilterSheet(BuildContext context, String storeId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(storeId: storeId),
    );
  }

  Future<void> _openSearchOverlay(String storeId) async {
    final query = await Navigator.of(context).push<String>(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black38,
        transitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (_, __, ___) => _SearchOverlay(storeId: storeId),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, -0.04),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOut),
                  ),
              child: child,
            ),
          );
        },
      ),
    );

    if (query != null && query.isNotEmpty && mounted) {
      await _RecentSearches.add(query);
      ref
          .read(productViewModelProvider.notifier)
          .searchProducts(storeId, query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;
    final storeState = ref.watch(storeViewModelProvider);
    final productState = ref.watch(productViewModelProvider);

    // Store change → reload
    ref.listen(storeViewModelProvider, (prev, next) {
      if (prev?.selectedStore?.storeId != next.selectedStore?.storeId &&
          next.selectedStore != null) {
        ref
            .read(productViewModelProvider.notifier)
            .loadForStore(next.selectedStore!.storeId);
      }
    });

    // Category selected from home screen → clear + fetch
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
            if (selectedStoreId == null) ...[
              _TappableSearchBar(
                isTablet: isTablet,
                currentQuery: '',
                onTap: () {},
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
              // Tappable search bar — opens overlay
              _TappableSearchBar(
                isTablet: isTablet,
                currentQuery: productState.searchQuery,
                onTap: () => _openSearchOverlay(selectedStoreId),
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
              _ProductModeHeader(
                title: headerTitle,
                isTablet: isTablet,
                onBack: () => _goBack(selectedStoreId),
              ),
              // Tappable search bar with filter button
              _SearchBarWithFilter(
                isTablet: isTablet,
                currentQuery: productState.searchQuery,
                hasActiveFilter: productState.filter.hasActiveFilters,
                onTap: () => _openSearchOverlay(selectedStoreId),
                onFilterTap: () => _showFilterSheet(context, selectedStoreId),
              ),
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

// Search Overlay

class _SearchOverlay extends StatefulWidget {
  final String storeId;
  const _SearchOverlay({required this.storeId});

  @override
  State<_SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends State<_SearchOverlay> {
  final TextEditingController _ctrl = TextEditingController();
  final FocusNode _focus = FocusNode();
  List<String> _recents = [];
  List<String> _filtered = [];

  @override
  void initState() {
    super.initState();
    _focus.requestFocus();
    _loadRecents();
    _ctrl.addListener(_onTyping);
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onTyping);
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _loadRecents() async {
    final list = await _RecentSearches.load();
    if (mounted) setState(() => _recents = list);
  }

  void _onTyping() {
    final q = _ctrl.text.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? []
          : _recents.where((r) => r.toLowerCase().contains(q)).toList();
    });
  }

  void _submit(String query) {
    final q = query.trim();
    if (q.isEmpty) return;
    Navigator.of(context).pop(q);
  }

  Future<void> _removeRecent(String query) async {
    await _RecentSearches.remove(query);
    _loadRecents();
  }

  Future<void> _clearAll() async {
    await _RecentSearches.clear();
    if (mounted) setState(() => _recents = []);
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;
    final showSuggestions = _ctrl.text.isNotEmpty && _filtered.isNotEmpty;
    final showRecents = _ctrl.text.isEmpty && _recents.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search input row
            Padding(
              padding: EdgeInsets.fromLTRB(8, isTablet ? 16 : 10, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                    ),
                    color: Colors.black87,
                  ),
                  Expanded(
                    child: Container(
                      height: isTablet ? 52 : 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F4F4),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: TextField(
                        controller: _ctrl,
                        focusNode: _focus,
                        textInputAction: TextInputAction.search,
                        onSubmitted: _submit,
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search products...',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: isTablet ? 15 : 13,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey.shade400,
                            size: isTablet ? 22 : 20,
                          ),
                          suffixIcon: _ctrl.text.isNotEmpty
                              ? GestureDetector(
                                  onTap: () => _ctrl.clear(),
                                  child: Icon(
                                    Icons.close_rounded,
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
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _submit(_ctrl.text),
                    child: Text(
                      'Search',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: isTablet ? 15 : 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: Color(0xFFEEEEEE)),

            // Suggestions
            if (showSuggestions)
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _filtered.length,
                  itemBuilder: (_, i) => _SuggestionTile(
                    query: _filtered[i],
                    icon: Icons.history_rounded,
                    onTap: () => _submit(_filtered[i]),
                    onFill: () {
                      _ctrl.text = _filtered[i];
                      _ctrl.selection = TextSelection.fromPosition(
                        TextPosition(offset: _ctrl.text.length),
                      );
                    },
                  ),
                ),
              )
            // Recent searches
            else if (showRecents)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
                      child: Row(
                        children: [
                          Text(
                            'Recent Searches',
                            style: TextStyle(
                              fontSize: isTablet ? 15 : 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: _clearAll,
                            child: Text(
                              'Clear all',
                              style: TextStyle(
                                fontSize: isTablet ? 14 : 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        itemCount: _recents.length,
                        itemBuilder: (_, i) => _SuggestionTile(
                          query: _recents[i],
                          icon: Icons.history_rounded,
                          onTap: () => _submit(_recents[i]),
                          onFill: () {
                            _ctrl.text = _recents[i];
                            _ctrl.selection = TextSelection.fromPosition(
                              TextPosition(offset: _ctrl.text.length),
                            );
                          },
                          trailing: GestureDetector(
                            onTap: () => _removeRecent(_recents[i]),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: Colors.black26,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            // Empty state
            else if (_ctrl.text.isEmpty && _recents.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.search_rounded,
                        size: 52,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Search for products',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: isTablet ? 16 : 14,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            // Typed but no matching recents
            else
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.keyboard_return_rounded,
                        size: 36,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Press search to find "${_ctrl.text}"',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: isTablet ? 15 : 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Suggestion Tile ──────────────────────────────────────────────────────────

class _SuggestionTile extends StatelessWidget {
  final String query;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback onFill;
  final Widget? trailing;

  const _SuggestionTile({
    required this.query,
    required this.icon,
    required this.onTap,
    required this.onFill,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey.shade400),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                query,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
            // Arrow fills search bar with this query without submitting
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
              const SizedBox(width: 4),
            ],
            GestureDetector(
              onTap: onFill,
              child: Icon(
                Icons.north_west_rounded,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Tappable Search Bar
class _TappableSearchBar extends StatelessWidget {
  final bool isTablet;
  final String currentQuery;
  final VoidCallback onTap;

  const _TappableSearchBar({
    required this.isTablet,
    required this.currentQuery,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, isTablet ? 20 : 14, 16, 12),
      child: GestureDetector(
        onTap: onTap,
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
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  Icons.search,
                  color: Colors.grey.shade400,
                  size: isTablet ? 24 : 20,
                ),
              ),
              Expanded(
                child: Text(
                  currentQuery.isNotEmpty ? currentQuery : 'Search products...',
                  style: TextStyle(
                    color: currentQuery.isNotEmpty
                        ? Colors.black87
                        : Colors.grey.shade400,
                    fontSize: isTablet ? 16 : 14,
                  ),
                ),
              ),
              if (currentQuery.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: Colors.grey.shade400,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Product Mode Header
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
  final bool isTablet;
  final String currentQuery;
  final bool hasActiveFilter;
  final VoidCallback onTap;
  final VoidCallback onFilterTap;

  const _SearchBarWithFilter({
    required this.isTablet,
    required this.currentQuery,
    required this.hasActiveFilter,
    required this.onTap,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onTap,
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
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(
                        Icons.search,
                        color: Colors.grey.shade400,
                        size: isTablet ? 22 : 20,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        currentQuery.isNotEmpty
                            ? currentQuery
                            : 'Search products...',
                        style: TextStyle(
                          color: currentQuery.isNotEmpty
                              ? Colors.black87
                              : Colors.grey.shade400,
                          fontSize: isTablet ? 15 : 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
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

// ─── Product List ─────────────────────────────────────────────────────────────

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

// ─── Filter Sheet ─────────────────────────────────────────────────────────────

class _FilterSheet extends ConsumerStatefulWidget {
  final String storeId;
  const _FilterSheet({required this.storeId});

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

    _snapshot = List.unmodifiable(productState.products);
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
                  const _FilterSectionTitle(title: 'Price Range'),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'NPR \${_priceRange.start.toInt()}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        _priceRange.end >= _maxBound
                            ? 'NPR \${_maxBound.toInt()}+'
                            : 'NPR \${_priceRange.end.toInt()}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
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
