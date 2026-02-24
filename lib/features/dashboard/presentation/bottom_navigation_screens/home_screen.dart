import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/apps/theme/app_colors.dart';
import 'package:project_ease/core/api/api_endpoints.dart';
import 'package:project_ease/core/utils/app_fonts.dart';
import 'package:project_ease/features/dashboard/presentation/product_detail_screen.dart';
import 'package:project_ease/features/product/domain/entities/category_entity.dart';
import 'package:project_ease/features/product/domain/entities/product_entity.dart';
import 'package:project_ease/features/product/presentation/state/product_state.dart';
import 'package:project_ease/features/product/presentation/view_model/product_view_model.dart';
import 'package:project_ease/features/store/presentation/view_model/store_view_model.dart';
import 'package:project_ease/features/store/presentation/widgets/store_dropdown.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final VoidCallback? onNavigateToSearch;

  const HomeScreen({super.key, this.onNavigateToSearch});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> adImages = [
    'assets/images/ad.png',
    'assets/images/ad.png',
    'assets/images/ad.png',
  ];

  @override
  Widget build(BuildContext context) {
    AppFonts.init(context);
    final bool isTablet = MediaQuery.of(context).size.width >= 600;
    final productState = ref.watch(productViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: isTablet ? 96 : kToolbarHeight,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Image.asset(
                'assets/images/ease_logo.png',
                height: isTablet ? 20 : 10,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'You are browsing at',
                      style: TextStyle(
                        fontSize: isTablet
                            ? AppFonts.labelLarge
                            : AppFonts.labelMedium,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 2),
                    StoreDropdown(isTablet: isTablet),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              iconSize: isTablet ? 32 : 24,
              icon: const Icon(Icons.notifications_none, color: Colors.black),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          final storeId = ref
              .read(storeViewModelProvider)
              .selectedStore
              ?.storeId;
          if (storeId != null) {
            await ref
                .read(productViewModelProvider.notifier)
                .loadForStore(storeId);
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildAdSlider(isTablet),
              const SizedBox(height: 12),
              _buildDotsIndicator(isTablet),
              const SizedBox(height: 20),

              // Categories
              _SectionHeader(title: 'Categories', isTablet: isTablet),
              const SizedBox(height: 10),
              _buildCategories(context, isTablet, productState),

              const SizedBox(height: 20),

              // For You
              _SectionHeader(title: 'FOR YOU', isTablet: isTablet),
              const SizedBox(height: 10),
              _buildProducts(isTablet, productState),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── Categories ──────────────────────────────────────────────────────────────

  Widget _buildCategories(
    BuildContext context,
    bool isTablet,
    ProductState productState,
  ) {
    if (productState.status == ProductStatus.loading &&
        productState.categories.isEmpty) {
      return SizedBox(
        height: 90,
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      );
    }

    if (productState.categories.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          'No categories available.',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
      );
    }

    return SizedBox(
      height: isTablet ? 110 : 88,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: productState.categories.length,
        itemBuilder: (_, i) => _CategoryChip(
          category: productState.categories[i],
          isTablet: isTablet,
          onTap: () {
            ref
                .read(productViewModelProvider.notifier)
                .navigateToCategory(productState.categories[i]);
            widget.onNavigateToSearch?.call();
          },
        ),
      ),
    );
  }

  // Products

  Widget _buildProducts(bool isTablet, ProductState productState) {
    if (productState.status == ProductStatus.loading &&
        productState.storeProducts.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final products = productState.storeProducts;

    if (products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.shopping_bag_outlined, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text('No products yet.', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isTablet ? 4 : 2,
          mainAxisExtent: isTablet ? 318 : 248,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: products.length,
        itemBuilder: (_, i) =>
            _HomeProductCard(product: products[i], isTablet: isTablet),
      ),
    );
  }

  Widget _buildAdSlider(bool isTablet) {
    final images = isTablet
        ? List.filled(3, 'assets/images/tab_ad.png')
        : adImages;
    return SizedBox(
      height: isTablet ? 240 : 160,
      child: PageView.builder(
        controller: _pageController,
        itemCount: images.length,
        onPageChanged: (i) => setState(() => _currentPage = i),
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              images[i],
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDotsIndicator(bool isTablet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        adImages.length,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == i ? (isTablet ? 12 : 8) : (isTablet ? 8 : 6),
          height: _currentPage == i ? (isTablet ? 12 : 8) : (isTablet ? 8 : 6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == i ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }
}

// Section Header

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isTablet;

  const _SectionHeader({required this.title, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title,
        style: TextStyle(
          fontSize: isTablet ? 18 : 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
          color: Colors.black87,
        ),
      ),
    );
  }
}

// Category Chip

class _CategoryChip extends StatelessWidget {
  final CategoryEntity category;
  final bool isTablet;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.category,
    required this.isTablet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = isTablet ? 110.0 : 88.0;
    final imageSize = isTablet ? 52.0 : 42.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: imageSize,
                height: imageSize,
                child: category.image != null
                    ? Image.network(
                        '${ApiEndpoints.mediaServerUrl}${category.image}',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(imageSize),
                      )
                    : _placeholder(imageSize),
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                category.name,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isTablet ? 12 : 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(double size) {
    return Container(
      color: AppColors.primary.withOpacity(0.08),
      child: Icon(
        Icons.category_outlined,
        color: AppColors.primary.withOpacity(0.4),
        size: size * 0.55,
      ),
    );
  }
}

// Home Product Card

class _HomeProductCard extends StatelessWidget {
  final ProductEntity product;
  final bool isTablet;

  const _HomeProductCard({required this.product, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final imageHeight = isTablet ? 200.0 : 160.0;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(product: product),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
              child: SizedBox(
                height: imageHeight,
                width: double.infinity,
                child: product.productImage != null
                    ? Image.network(
                        '${ApiEndpoints.mediaServerUrl}${product.productImage}',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _imagePlaceholder(imageHeight),
                      )
                    : _imagePlaceholder(imageHeight),
              ),
            ),
            // Details
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isTablet ? 13 : 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'NPR ${product.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder(double height) {
    return Container(
      height: height,
      color: Colors.grey.shade100,
      child: Icon(
        Icons.image_outlined,
        color: Colors.grey.shade300,
        size: height * 0.35,
      ),
    );
  }
}
