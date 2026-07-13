import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/features/user/market/presentation/widgets/market_section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/widgets/screen_background.dart';
import 'package:fitness_day/features/user/market/domain/entities/product_data.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/user_app_drawer.dart';
import 'package:fitness_day/features/user/market/presentation/screens/products_list_screen.dart';
import 'package:fitness_day/features/user/market/presentation/screens/cart_screen.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/subscription_banner.dart';
import 'package:fitness_day/features/user/market/presentation/widgets/package_details_dialog.dart';
import 'package:fitness_day/features/user/market/presentation/widgets/market_app_bar.dart';
import 'package:fitness_day/features/user/market/presentation/widgets/market_tab_bar.dart';
import 'package:fitness_day/features/user/market/presentation/widgets/market_categories_row.dart';
import 'package:fitness_day/features/user/market/presentation/widgets/market_products_grid.dart';
import 'package:fitness_day/core/widgets/app_image.dart';

class MarketMainScreen extends StatefulWidget {
  const MarketMainScreen({super.key});

  @override
  State<MarketMainScreen> createState() => _MarketMainScreenState();
}

class _MarketMainScreenState extends State<MarketMainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedCategoryIndex = 0;

  List<String> get _categories => [
        'market.category_all'.tr(),
        'market.category_slimming'.tr(),
        'market.category_supplements'.tr(),
        'market.category_snacks'.tr(),
      ];

  // Dummy Data for UI demonstration
  late final List<ProductData> _dummyProducts = [
    ProductData(
      id: '1',
      name: 'market.mock_product_diet_coffee'.tr(),
      imageUrl:
          'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=400',
      currentPrice: 3500,
      oldPrice: 5000,
      discountTag: 'market.mock_discount_tag'.tr(),
      offerTag: 'market.mock_offer_tag'.tr(),
      isFavorite: true,
    ),
    ProductData(
      id: '2',
      name: 'market.mock_product_diet_coffee'.tr(),
      imageUrl:
          'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=400',
      currentPrice: 3500,
      oldPrice: 5000,
      discountTag: 'market.mock_discount_tag'.tr(),
      offerTag: 'market.mock_offer_tag'.tr(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleFavorite(ProductData product) {
    setState(() {
      final idx = _dummyProducts.indexWhere((item) => item.id == product.id);
      if (idx != -1) {
        final old = _dummyProducts[idx];
        _dummyProducts[idx] = ProductData(
          id: old.id,
          name: old.name,
          imageUrl: old.imageUrl,
          currentPrice: old.currentPrice,
          oldPrice: old.oldPrice,
          isFavorite: !old.isFavorite,
          discountTag: old.discountTag,
          offerTag: old.offerTag,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const UserAppDrawer(),
      body: ScreenBackground(
        child: SafeArea(
          child: Column(
            children: [
              MarketAppBar(
                onCartTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                ),
              ),
              SizedBox(height: 12.h),
              MarketTabBar(controller: _tabController),
              SizedBox(height: 16.h),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildProductsTab(),
                    _buildPackagesTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── PRODUCTS TAB CONTENT ────────────────────────────────────────────────────
  Widget _buildProductsTab() {
    final isAllCategory = _selectedCategoryIndex == 0;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Categories
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(bottom: isAllCategory ? 0 : 16.h),
            child: MarketCategoriesRow(
              categories: _categories,
              selectedIndex: _selectedCategoryIndex,
              onSelect: (index) =>
                  setState(() => _selectedCategoryIndex = index),
            ),
          ),
        ),

        if (isAllCategory) ...[
          // Banner 1
          _buildPromoBanner(),

          // Best Offers Section
          SliverToBoxAdapter(
            child: MarketSectionHeader(
              title: 'market.best_offers_section'.tr(),
              onMoreTap: () => _openProductsList(
                'market.best_offers_section'.tr(),
              ),
            ),
          ),
          MarketProductsGrid(
            products: _dummyProducts,
            onFavoriteTap: _toggleFavorite,
          ),

          // Banner 2
          _buildPromoBanner(),

          // Best Sellers Section
          SliverToBoxAdapter(
            child: MarketSectionHeader(
              title: 'market.best_sellers_section'.tr(),
              onMoreTap: () => _openProductsList(
                'market.best_sellers_section'.tr(),
              ),
            ),
          ),
          MarketProductsGrid(
            products: _dummyProducts,
            onFavoriteTap: _toggleFavorite,
          ),

          // Latest Products Section
          SliverToBoxAdapter(
            child: MarketSectionHeader(
              title: 'market.latest_products_section'.tr(),
              onMoreTap: () => _openProductsList(
                'market.latest_products_section'.tr(),
              ),
            ),
          ),
          MarketProductsGrid(
            products: _dummyProducts,
            onFavoriteTap: _toggleFavorite,
          ),
        ] else ...[
          MarketProductsGrid(
            products: _dummyProducts,
            onFavoriteTap: _toggleFavorite,
          ),
        ],

        SliverPadding(padding: EdgeInsets.only(bottom: 40.h)),
      ],
    );
  }

  Widget _buildPromoBanner() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: AppImage(
            "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800",
            height: 170.h,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  void _openProductsList(String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductsListScreen(
          title: title,
          products: _dummyProducts,
        ),
      ),
    );
  }

  // ── PACKAGES TAB CONTENT ───────────────────────────────────────────────────
  Widget _buildPackagesTab() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(padding: EdgeInsets.only(top: 16.h)),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            child: SubscriptionBanner(
              isSubscribed: true,
              subscriptionName: 'market.subscribed_package_message'.tr(),
              subscriptionEndDate: '2026-07-16T00:00:00.000Z',
              onSubscribedTap: () {
                showDialog(
                  context: context,
                  barrierColor: AppColors.black.withValues(alpha: 0.6),
                  builder: (context) => PackageDetailsDialog(
                    // Use a dummy product to represent the current package
                    package: _dummyProducts[0],
                    isSubscribed: true,
                    expiryDate: '4/8/2026',
                  ),
                );
              },
            ),
          ),
        ),
        SliverPadding(padding: EdgeInsets.only(top: 8.h)),
        MarketProductsGrid(
          products: _dummyProducts,
          detailsLabelKey: 'market.details_button',
          onDetailsTap: _showPackageDetails,
          onItemTap: _showPackageDetails,
          onFavoriteTap: _toggleFavorite,
        ),
        SliverPadding(padding: EdgeInsets.only(bottom: 40.h)),
      ],
    );
  }

  void _showPackageDetails(ProductData package) {
    showDialog(
      context: context,
      barrierColor: AppColors.black.withValues(alpha: 0.6),
      builder: (context) => PackageDetailsDialog(package: package),
    );
  }
}
