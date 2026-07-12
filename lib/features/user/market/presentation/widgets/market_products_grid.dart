import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/features/user/market/domain/entities/product_data.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/subscription_package_card.dart';
import 'package:fitness_day/features/user/market/presentation/screens/product_details_screen.dart';

/// Sliver grid of product/package cards, reused by both the products and
/// packages tabs on the market main screen.
class MarketProductsGrid extends StatelessWidget {
  final List<ProductData> products;
  final String detailsLabelKey;
  final void Function(ProductData product)? onItemTap;
  final void Function(ProductData product)? onFavoriteTap;
  final void Function(ProductData product)? onDetailsTap;

  const MarketProductsGrid({
    super.key,
    required this.products,
    this.detailsLabelKey = 'home.add_to_cart',
    this.onItemTap,
    this.onFavoriteTap,
    this.onDetailsTap,
  });

  @override
  Widget build(BuildContext context) {
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
                ? () => onItemTap!(p)
                : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailsScreen(product: p),
                      ),
                    ),
            onFavoriteTap: () => onFavoriteTap?.call(p),
            // Always provide a non-null onDetailsTap so button stays enabled
            onDetailsTap: onDetailsTap != null
                ? () => onDetailsTap!(p)
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
