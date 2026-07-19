import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:fitness_day/core/widgets/screen_background.dart';
import 'package:fitness_day/features/user/market/domain/entities/plans_data.dart';
import 'package:fitness_day/features/user/market/domain/entities/product_data.dart';
import 'package:fitness_day/features/user/market/domain/entities/store_home_data.dart';
import 'package:fitness_day/features/user/market/presentation/manager/market_home_cubit.dart';
import 'package:fitness_day/features/user/market/presentation/manager/market_home_state.dart';
import 'package:fitness_day/features/user/market/presentation/manager/plans_cubit.dart';
import 'package:fitness_day/features/user/market/presentation/screens/cart_screen.dart';
import 'package:fitness_day/features/user/market/presentation/screens/products_list_screen.dart';
import 'package:fitness_day/features/user/market/presentation/widgets/market_app_bar.dart';
import 'package:fitness_day/features/user/market/presentation/widgets/market_categories_row.dart';
import 'package:fitness_day/features/user/market/presentation/widgets/market_products_grid.dart';
import 'package:fitness_day/features/user/market/presentation/widgets/market_section_header.dart';
import 'package:fitness_day/features/user/market/presentation/widgets/market_tab_bar.dart';
import 'package:fitness_day/features/user/market/presentation/widgets/package_details_dialog.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/subscription_banner.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/subscription_package_card.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/user_app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MarketMainScreen extends StatefulWidget {
  const MarketMainScreen({super.key});

  @override
  State<MarketMainScreen> createState() => _MarketMainScreenState();
}

class _MarketMainScreenState extends State<MarketMainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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

  /// Maps a [StoreProductItem] to the legacy [ProductData] entity used by
  /// existing product cards and dialogs.
  ProductData _toProductData(StoreProductItem item) {
    return ProductData(
      id: item.id,
      name: item.name,
      imageUrl: item.mainPhoto,
      currentPrice: item.price,
      oldPrice: item.compareAtPrice,
      isFavorite: item.isFavorite,
      discountTag: item.badge,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<MarketHomeCubit>()..loadStoreHome(),
        ),
        BlocProvider(
          create: (_) => getIt<PlansCubit>()..load(),
        ),
      ],
      child: Scaffold(
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
                      _ProductsTab(
                        toProductData: _toProductData,
                      ),
                      const _PackagesTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Products Tab
// ─────────────────────────────────────────────────────────────────────────────
class _ProductsTab extends StatelessWidget {
  final ProductData Function(StoreProductItem) toProductData;

  const _ProductsTab({required this.toProductData});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MarketHomeCubit, MarketHomeState>(
      builder: (context, state) {
        if (state is MarketHomeLoading || state is MarketHomeInitial) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (state is MarketHomeFailure) {
          return Center(
            child: Text(state.message, style: TextStyleManager.style14Medium),
          );
        }

        if (state is! MarketHomeSuccess) return const SizedBox.shrink();

        final data = state.data;
        final isAllCategory = state.selectedCategoryIndex == 0;

        // Build category list: "All" + API categories
        final categoryNames = [
          'market.category_all'.tr(),
          ...data.categories.map((c) => c.name),
        ];

        // Filter products when a specific category is selected
        final selectedCategoryId = state.selectedCategoryIndex > 0
            ? data.categories[state.selectedCategoryIndex - 1].id
            : null;

        List<ProductData> filteredBestOffers = data.bestOffers
            .where((p) => selectedCategoryId == null || p.category?.id == selectedCategoryId)
            .map(toProductData)
            .toList();
        List<ProductData> filteredNewProducts = data.newProducts
            .where((p) => selectedCategoryId == null || p.category?.id == selectedCategoryId)
            .map(toProductData)
            .toList();
        List<ProductData> filteredBestSellers = data.bestSellers
            .where((p) => selectedCategoryId == null || p.category?.id == selectedCategoryId)
            .map(toProductData)
            .toList();

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Categories row
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(bottom: isAllCategory ? 0 : 16.h),
                child: MarketCategoriesRow(
                  categories: categoryNames,
                  selectedIndex: state.selectedCategoryIndex,
                  onSelect: (i) {
                    context.read<MarketHomeCubit>().selectCategory(i);
                    if (i > 0) {
                      final catId = data.categories[i - 1].id;
                      final catName = data.categories[i - 1].name;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductsListScreen.byCategory(
                            title: catName,
                            categoryId: catId,
                          ),
                        ),
                      ).then((_) {
                        if (context.mounted) {
                          context.read<MarketHomeCubit>().selectCategory(0);
                        }
                      });
                    }
                  },
                ),
              ),
            ),

            if (isAllCategory) ...[
              // Header banner carousel
              if (data.headerBanners.isNotEmpty)
                SliverToBoxAdapter(child: _BannerCarousel(banners: data.headerBanners)),

              // Best Offers
              if (filteredBestOffers.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: MarketSectionHeader(
                    title: 'market.best_offers_section'.tr(),
                    onMoreTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductsListScreen.byType(
                          title: 'market.best_offers_section'.tr(),
                          type: 'BEST_OFFERS',
                        ),
                      ),
                    ),
                  ),
                ),
                MarketProductsGrid(products: filteredBestOffers),
              ],

              // Middle banner
              if (data.middleBanners.isNotEmpty)
                SliverToBoxAdapter(
                  child: _SingleBanner(banner: data.middleBanners.first),
                ),

              // Best Sellers
              if (filteredBestSellers.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: MarketSectionHeader(
                    title: 'market.best_sellers_section'.tr(),
                    onMoreTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductsListScreen.byType(
                          title: 'market.best_sellers_section'.tr(),
                          type: 'BEST_SELLERS',
                        ),
                      ),
                    ),
                  ),
                ),
                MarketProductsGrid(products: filteredBestSellers),
              ],

              // New Products
              if (filteredNewProducts.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: MarketSectionHeader(
                    title: 'market.latest_products_section'.tr(),
                    onMoreTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductsListScreen.byType(
                          title: 'market.latest_products_section'.tr(),
                          type: 'NEW_PRODUCTS',
                        ),
                      ),
                    ),
                  ),
                ),
                MarketProductsGrid(products: filteredNewProducts),
              ],
            ] else ...[
              // Filtered category — show all matching products together
              MarketProductsGrid(
                products: [
                  ...filteredBestOffers,
                  ...filteredBestSellers,
                  ...filteredNewProducts,
                ],
              ),
            ],

            SliverPadding(padding: EdgeInsets.only(bottom: 40.h)),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Packages Tab — driven by PlansCubit → GET /plans
// ─────────────────────────────────────────────────────────────────────────────
class _PackagesTab extends StatelessWidget {
  const _PackagesTab();

  void _showPlanDetails(BuildContext context, PlanItem plan) {
    showDialog(
      context: context,
      barrierColor: AppColors.black.withValues(alpha: 0.6),
      builder: (_) => PackageDetailsDialog(planId: plan.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlansCubit, PlansState>(
      builder: (context, state) {
        if (state is PlansLoading || state is PlansInitial) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        if (state is PlansFailure) {
          return Center(
            child: Text(state.message, style: TextStyleManager.style14Medium),
          );
        }
        if (state is! PlansSuccess) return const SizedBox.shrink();

        final sub = state.data.currentSubscription;
        final plans = state.data.plans;

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(padding: EdgeInsets.only(top: 16.h)),

            // Current subscription banner
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                child: SubscriptionBanner(
                  isSubscribed: sub != null,
                  subscriptionName: sub?.name ?? 'market.subscribed_package_message'.tr(),
                  subscriptionEndDate: sub?.endDate ?? '',
                  onSubscribedTap: sub == null
                      ? null
                      : () {
                          final plan = plans.firstWhere(
                            (p) => p.name == sub.name,
                            orElse: () => plans.first,
                          );
                          showDialog(
                            context: context,
                            barrierColor: AppColors.black.withValues(alpha: 0.6),
                            builder: (_) => PackageDetailsDialog(
                              planId: plan.id,
                              isSubscribed: true,
                              expiryDate: sub.endDate,
                            ),
                          );
                        },
                ),
              ),
            ),

            SliverPadding(padding: EdgeInsets.only(top: 8.h)),

            // Plans grid
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.w,
                  mainAxisSpacing: 16.h,
                  childAspectRatio: 0.58,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final plan = plans[index];
                    final package = SubscriptionPackageData(
                      id: plan.id,
                      imageUrl: plan.coverPhoto,
                      name: plan.name,
                      currentPrice: plan.price.toInt(),
                      oldPrice: plan.compareAtPrice?.toInt() ?? 0,
                      isFavorite: plan.isFavorite,
                    );
                    return SubscriptionPackageCard(
                      package: package,
                      badge: plan.badge,
                      detailsLabelKey: 'market.details_button',
                      onTap: () => _showPlanDetails(context, plan),
                      onDetailsTap: () => _showPlanDetails(context, plan),
                    );
                  },
                  childCount: plans.length,
                ),
              ),
            ),

            SliverPadding(padding: EdgeInsets.only(bottom: 40.h)),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Banner Carousel (header banners)
// ─────────────────────────────────────────────────────────────────────────────
class _BannerCarousel extends StatefulWidget {
  final List<BannerItem> banners;

  const _BannerCarousel({required this.banners});

  @override
  State<_BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<_BannerCarousel> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: SizedBox(
              height: 160.h,
              child: PageView.builder(
                controller: _controller,
                itemCount: widget.banners.length,
                onPageChanged: (i) => setState(() => _currentIndex = i),
                itemBuilder: (_, i) => AppImage(
                  widget.banners[i].photo,
                  height: 160.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          if (widget.banners.length > 1) ...[
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.banners.length, (i) {
                final isActive = i == _currentIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: EdgeInsets.symmetric(horizontal: 3.w),
                  width: isActive ? 20.w : 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : AppColors.divider,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Single Banner (middle banner)
// ─────────────────────────────────────────────────────────────────────────────
class _SingleBanner extends StatelessWidget {
  final BannerItem banner;

  const _SingleBanner({required this.banner});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: AppImage(
          banner.photo,
          height: 170.h,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
