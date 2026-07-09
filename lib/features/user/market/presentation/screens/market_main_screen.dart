import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fitness_day/core/theme/app_shadows.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/widgets/screen_background.dart';
import 'package:fitness_day/features/user/market/domain/entities/product_data.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/subscription_package_card.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/user_app_drawer.dart';
import 'package:fitness_day/features/user/market/presentation/screens/products_list_screen.dart';
import 'package:fitness_day/features/user/market/presentation/screens/product_details_screen.dart';
import 'package:fitness_day/features/user/market/presentation/screens/cart_screen.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/subscription_banner.dart';
import 'package:fitness_day/features/user/market/presentation/widgets/package_details_dialog.dart';

class MarketMainScreen extends StatefulWidget {
  const MarketMainScreen({super.key});

  @override
  State<MarketMainScreen> createState() => _MarketMainScreenState();
}

class _MarketMainScreenState extends State<MarketMainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedCategoryIndex = 0;

  final List<String> _categories = [
    'الكل',
    'منتجات التنحيف',
    'مكملات غذائية',
    'سناكات صحية',
  ];

  // Dummy Data for UI demonstration
  final List<ProductData> _dummyProducts = [
    ProductData(
      id: '1',
      name: 'قهوة تنحيف دايت سبريم الاقتصادي، نكهة القهوة 2 كيلو 50 سكوب',
      imageUrl: 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=400',
      currentPrice: 3500,
      oldPrice: 5000,
      discountTag: '50% لفترة محدودة',
      offerTag: 'حبة + حبة مجاناً',
      isFavorite: true,
    ),
    ProductData(
      id: '2',
      name: 'قهوة تنحيف دايت سبريم الاقتصادي، نكهة القهوة 2 كيلو 50 سكوب',
      imageUrl: 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=400',
      currentPrice: 3500,
      oldPrice: 5000,
      discountTag: '50% لفترة محدودة',
      offerTag: 'حبة + حبة مجاناً',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const UserAppDrawer(),
      body: ScreenBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              SizedBox(height: 12.h),
              _buildTabBar(),
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

  // ── APP BAR ─────────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            'المتجر',
            textAlign: TextAlign.center,
            style: TextStyleManager.heading2.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.w800,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  );
                },
                child: Container(
                  width: 44.w,
                  height: 44.w,
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.textSecondary.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: SvgPicture.asset(
                    SvgIcons.market_icon,
                    colorFilter: const ColorFilter.mode(
                      AppColors.textSecondary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              // Menu
              Builder(
                builder: (ctx) => GestureDetector(
                  onTap: () => Scaffold.of(ctx).openEndDrawer(),
                  child: Container(
                    width: 44.w,
                    height: 44.w,
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.textSecondary.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: SvgPicture.asset(
                      SvgIcons.menuIcon,
                      colorFilter: const ColorFilter.mode(
                        AppColors.textSecondary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── TAB BAR ─────────────────────────────────────────────────────────────────
  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30.w),
      child: TabBar(
        controller: _tabController,
        // Indicator only for the selected tab; make it slightly wider
        // than the label by using label size with negative horizontal insets.
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: AppColors.primary, width: 4),
          insets: EdgeInsets.symmetric(horizontal: -50.w),
        ),
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: TextStyleManager.style13Medium.copyWith(fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyleManager.style13Medium,
        tabs: const [
          Tab(text: 'المنتجات'),
          Tab(text: 'الباقات'),
        ],
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
            child: _buildCategoriesRow(),
          ),
        ),

        if (isAllCategory) ...[
          // Banner 1
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Image.network(
                  "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800",
                  height: 170.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Best Offers Section
          SliverToBoxAdapter(
            child: _buildSectionHeader('اقوى العروض', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductsListScreen(
                    title: 'اقوى العروض',
                    products: _dummyProducts,
                  ),
                ),
              );
            }),
          ),
          _buildProductsGrid(_dummyProducts, detailsLabelKey: 'home.add_to_cart'),

          // Banner 2
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Image.network(
                  "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800",
                  height: 170.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Best Sellers Section
          SliverToBoxAdapter(
            child: _buildSectionHeader('الاكثر مبيعا', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductsListScreen(
                    title: 'الاكثر مبيعا',
                    products: _dummyProducts,
                  ),
                ),
              );
            }),
          ),
          _buildProductsGrid(_dummyProducts, detailsLabelKey: 'home.add_to_cart'),

          // Latest Products Section
          SliverToBoxAdapter(
            child: _buildSectionHeader('احدث المنتجات', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductsListScreen(
                    title: 'احدث المنتجات',
                    products: _dummyProducts,
                  ),
                ),
              );
            }),
          ),
          _buildProductsGrid(_dummyProducts, detailsLabelKey: 'home.add_to_cart'),
        ] else ...[
          _buildProductsGrid(_dummyProducts, detailsLabelKey: 'home.add_to_cart'),
        ],

        SliverPadding(padding: EdgeInsets.only(bottom: 40.h)),
      ],
    );
  }

  // ── CATEGORIES ──────────────────────────────────────────────────────────────
  Widget _buildCategoriesRow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        // height: 44.h,
        padding: EdgeInsets.symmetric(vertical: 3.w),
    
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(28.r),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(_categories.length, (index) {
              final isSelected = _selectedCategoryIndex == index;
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedCategoryIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
                    decoration: isSelected
                        ? BoxDecoration(
                            color: Color(0xFFECFBEE),
                            borderRadius: BorderRadius.circular(20.r),
                            boxShadow: AppShadows.primaryShadow,
                          )
                        : BoxDecoration(borderRadius: BorderRadius.circular(20.r)),
                    child: Text(
                      _categories[index],
                      style: TextStyleManager.style11Medium.copyWith(
                        color: isSelected ? AppColors.primary : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  // ── SECTION HEADER ──────────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title, VoidCallback onMoreTap) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyleManager.heading3.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: onMoreTap,
            child: Row(
              children: [
              
                Text(
                  'المزيد',
                  style: TextStyleManager.style11Medium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 4.w),

                  Icon(
                  Icons.keyboard_double_arrow_left,
                  size: 16.sp,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
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
              packageName: 'انت الآن مشترك في باقة صحي',
              expiryDate: '2026/ 16/7',
              onSubscribedTap: () {
                showDialog(
                  context: context,
                  barrierColor: Colors.black.withValues(alpha: 0.6),
                  builder: (context) => PackageDetailsDialog(
                    package: _dummyProducts[0], // Use a dummy product to represent the current package
                    isSubscribed: true,
                    expiryDate: '4/8/2026',
                  ),
                );
              },
            ),
          ),
        ),
        SliverPadding(padding: EdgeInsets.only(top: 8.h)),
        _buildProductsGrid(
          _dummyProducts,
          detailsLabelKey: 'تفاصيل',
          onDetailsTap: (package) {
            showDialog(
              context: context,
              barrierColor: Colors.black.withValues(alpha: 0.6),
              builder: (context) => PackageDetailsDialog(package: package),
            );
          },
          onItemTap: (package) {
            showDialog(
              context: context,
              barrierColor: Colors.black.withValues(alpha: 0.6),
              builder: (context) => PackageDetailsDialog(package: package),
            );
          },
          onFavoriteTap: (product) {}, // handled internally in _buildProductsGrid
        ),
        SliverPadding(padding: EdgeInsets.only(bottom: 40.h)),
      ],
    );
  }

  // ── PRODUCTS GRID ───────────────────────────────────────────────────────────
  Widget _buildProductsGrid(
    List<ProductData> products, {
    String detailsLabelKey = 'home.add_to_cart',
    void Function(ProductData)? onItemTap,
    void Function(ProductData)? onFavoriteTap,
    void Function(ProductData)? onDetailsTap,
  }) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.w,
          mainAxisSpacing: 16.h,
          childAspectRatio: 0.58,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final p = products[index];
          final package = SubscriptionPackageData(
            imageUrl: p.imageUrl,
            name: p.name,
            currentPrice: p.currentPrice.toInt(),
            oldPrice: p.oldPrice?.toInt() ?? 0,
            isFavorite: p.isFavorite,
          );
          return SubscriptionPackageCard(
            package: package,
            detailsLabelKey: detailsLabelKey,
            onTap: onItemTap != null
                ? () => onItemTap(p)
                : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailsScreen(product: p),
                      ),
                    ),
            // Toggle favorite with setState so UI updates immediately
            onFavoriteTap: () {
              setState(() {
                final idx = _dummyProducts.indexWhere((item) => item.id == p.id);
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
              // Also call external callback if provided (e.g. packages tab)
              onFavoriteTap?.call(p);
            },
            // Always provide a non-null onDetailsTap so button stays enabled
            onDetailsTap: onDetailsTap != null
                ? () => onDetailsTap(p)
                : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailsScreen(product: p),
                      ),
                    ),
          );
        }, childCount: products.length),
      ),
    );
  }


}
