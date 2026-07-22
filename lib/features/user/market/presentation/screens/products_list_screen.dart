import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/widgets/network_error_view.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:fitness_day/core/widgets/screen_background.dart';
import 'package:fitness_day/features/user/market/domain/entities/cart_data.dart';
import 'package:fitness_day/features/user/market/domain/entities/product_data.dart';
import 'package:fitness_day/features/user/market/domain/entities/products_page_data.dart';
import 'package:fitness_day/features/user/market/domain/entities/store_home_data.dart';
import 'package:fitness_day/features/user/market/domain/usecases/get_products_usecase.dart';
import 'package:fitness_day/features/user/market/presentation/manager/products_list_cubit.dart';
import 'package:fitness_day/features/user/market/presentation/manager/products_list_state.dart';
import 'package:fitness_day/features/user/market/presentation/screens/product_details_screen.dart';
import 'package:fitness_day/features/user/market/presentation/widgets/product_card_shimmer.dart';
import 'package:fitness_day/features/user/market/presentation/widgets/product_cart_card.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/subscription_package_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductsListScreen extends StatelessWidget {
  final String title;
  final ProductsFilter filter;

  /// Legacy constructor — passes a static list (kept for backward compat).
  /// Prefer using [ProductsListScreen.withFilter] for real API data.
  const ProductsListScreen({
    super.key,
    required this.title,
    required this.filter,
  });

  /// Convenience factory for section "more" taps.
  factory ProductsListScreen.byType({
    required String title,
    required String type,
  }) {
    return ProductsListScreen(
      title: title,
      filter: ProductsFilter.byType(type),
    );
  }

  factory ProductsListScreen.byCategory({
    required String title,
    required String categoryId,
  }) {
    return ProductsListScreen(
      title: title,
      filter: ProductsFilter.byCategory(categoryId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductsListCubit(
        getProductsUseCase: getIt<GetProductsUseCase>(),
        filter: filter,
      )..loadFirst(),
      child: _ProductsListView(title: title),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// View (stateful for scroll controller)
// ─────────────────────────────────────────────────────────────────────────────
class _ProductsListView extends StatefulWidget {
  final String title;

  const _ProductsListView({required this.title});

  @override
  State<_ProductsListView> createState() => _ProductsListViewState();
}

class _ProductsListViewState extends State<_ProductsListView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    // Trigger load-more when 200px from the bottom
    if (currentScroll >= maxScroll - 200) {
      context.read<ProductsListCubit>().loadMore();
    }
  }

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
    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: Column(
            children: [
              _AppBar(title: widget.title),
              Expanded(
                child: BlocBuilder<ProductsListCubit, ProductsListState>(
                  builder: (context, state) {
                    if (state is ProductsListLoading) {
                      return const ProductsGridShimmer();
                    }

                    if (state is ProductsListFailure) {
                      return NetworkErrorView(
                        onRetry: () => context.read<ProductsListCubit>().loadFirst(),
                      );
                    }

                    if (state is ProductsListSuccess) {
                      if (state.products.isEmpty) {
                        return Center(
                          child: Text(
                            'market.no_products'.tr(),
                            style: TextStyleManager.style14Medium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        );
                      }

                      return GridView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 40.h),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16.w,
                          mainAxisSpacing: 16.h,
                          childAspectRatio: 0.58,
                        ),
                        // +1 for the loading indicator at the bottom
                        itemCount: state.products.length + (state.isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == state.products.length) {
                            // Loading more indicator
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          }

                          final item = state.products[index];
                          final product = _toProductData(item);
                          final package = SubscriptionPackageData(
                            id: product.id,
                            imageUrl: product.imageUrl,
                            name: product.name,
                            currentPrice: product.currentPrice.toInt(),
                            oldPrice: product.oldPrice?.toInt() ?? 0,
                            isFavorite: product.isFavorite,
                          );

                          return ProductCartCard(
                            package: package,
                            itemType: CartItemType.product,
                            badge: product.discountTag,
                            detailsLabelKey: 'market.add_to_cart',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailsScreen(product: product),
                              ),
                            ),
                          );
                        },
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// App Bar
// ─────────────────────────────────────────────────────────────────────────────
class _AppBar extends StatelessWidget {
  final String title;

  const _AppBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back_ios_rounded,
              color: AppColors.black,
              size: 20.sp,
            ),
          ),
          const Spacer(),
          Text(
            title,
            style: TextStyleManager.heading2.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          Container(
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
            child: AppImage(
              SvgIcons.market_icon,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
