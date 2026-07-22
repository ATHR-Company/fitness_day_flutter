import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/screen_background.dart';
import 'package:fitness_day/features/user/market/domain/entities/plans_data.dart';
import 'package:fitness_day/features/user/market/domain/entities/product_data.dart';
import 'package:fitness_day/features/user/market/domain/entities/store_home_data.dart';
import 'package:fitness_day/features/user/market/presentation/manager/favorites_cubit.dart';
import 'package:fitness_day/features/user/market/presentation/widgets/market_products_grid.dart';
import 'package:fitness_day/features/user/market/presentation/widgets/package_details_dialog.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/subscription_package_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The user's favourited products and packages, rendered with the same cards
/// as the store grids.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<FavoritesCubit>()..load(),
      child: const _FavoritesView(),
    );
  }
}

class _FavoritesView extends StatelessWidget {
  const _FavoritesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: Column(
            children: [
              _AppBar(title: 'market.favorites_title'.tr()),
              Expanded(
                child: BlocBuilder<FavoritesCubit, FavoritesState>(
                  builder: (context, state) {
                    if (state is FavoritesLoading || state is FavoritesInitial) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      );
                    }

                    if (state is FavoritesFailure) {
                      return _Message(
                        text: state.message,
                        onRetry: () => context.read<FavoritesCubit>().load(),
                      );
                    }

                    if (state is FavoritesSuccess) {
                      if (state.data.isEmpty) {
                        return _Message(text: 'market.favorites_empty'.tr());
                      }
                      return _FavoritesList(
                        products: state.data.products,
                        plans: state.data.plans,
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

class _FavoritesList extends StatelessWidget {
  final List<StoreProductItem> products;
  final List<PlanItem> plans;

  const _FavoritesList({required this.products, required this.plans});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        if (products.isNotEmpty) ...[
          _sectionHeader('market.tab_products'.tr()),
          // The store's own grid — same card, metrics and tap behaviour, so
          // favourites can never drift out of sync with the store visually.
          MarketProductsGrid(products: products.map(_toProductData).toList()),
        ],
        if (plans.isNotEmpty) ...[
          _sectionHeader('market.tab_packages'.tr()),
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
                  return SubscriptionPackageCard(
                    package: SubscriptionPackageData(
                      id: plan.id,
                      imageUrl: plan.coverPhoto,
                      name: plan.name,
                      currentPrice: plan.price.toInt(),
                      oldPrice: plan.compareAtPrice?.toInt() ?? 0,
                      isFavorite: plan.isFavorite,
                    ),
                    badge: plan.badge,
                    detailsLabelKey: 'market.details_button',
                    onTap: () => _showPlanDetails(context, plan.id),
                    onDetailsTap: () => _showPlanDetails(context, plan.id),
                  );
                },
                childCount: plans.length,
              ),
            ),
          ),
        ],
        SliverPadding(padding: EdgeInsets.only(bottom: 40.h)),
      ],
    );
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

  void _showPlanDetails(BuildContext context, String planId) {
    showDialog(
      context: context,
      barrierColor: AppColors.black.withValues(alpha: 0.6),
      builder: (_) => PackageDetailsDialog(planId: planId),
    );
  }

  Widget _sectionHeader(String title) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
      sliver: SliverToBoxAdapter(
        child: Text(
          title,
          style: TextStyleManager.heading3.copyWith(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final String text;
  final VoidCallback? onRetry;

  const _Message({required this.text, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_border, size: 48.sp, color: AppColors.divider),
            SizedBox(height: 12.h),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyleManager.style13Medium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (onRetry != null) ...[
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: Text(
                  'common.retry'.tr(),
                  style: const TextStyle(color: AppColors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  final String title;

  const _AppBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyleManager.heading2.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.w800,
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.textSecondary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.arrow_back_ios_rounded,
                  size: 18.sp,
                  color: AppColors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
