import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_shadows.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/user/market/domain/entities/product_data.dart';
import 'package:fitness_day/features/user/market/presentation/screens/product_details_screen.dart';

class ProductCard extends StatelessWidget {
  final ProductData product;
  final VoidCallback? onAddToCart;
  final VoidCallback? onFavoriteToggle;

  const ProductCard({
    super.key,
    required this.product,
    this.onAddToCart,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.divider, width: 0.5),
        boxShadow: AppShadows.primaryShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Image & Badges ──────────────────────────────────────────────
          Expanded(
            child: Stack(
              children: [
                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.r),
                    topRight: Radius.circular(16.r),
                  ),
                  child: Image.network(
                    product.imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.backgroundTint,
                      child: Center(
                        child: Icon(Icons.image_outlined, color: AppColors.greenMint),
                      ),
                    ),
                  ),
                ),
                
                // Favorite Button (Top Left)
                PositionedDirectional(
                  top: 8.h,
                  start: 8.w,
                  child: GestureDetector(
                    onTap: onFavoriteToggle,
                    child: Container(
                      padding: EdgeInsets.all(6.r),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: AppShadows.primaryShadow,
                      ),
                      child: Icon(
                        product.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: AppColors.marketGreen,
                        size: 20.sp,
                      ),
                    ),
                  ),
                ),

                // Tags (Top Right)
                PositionedDirectional(
                  top: 8.h,
                  end: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (product.discountTag != null)
                        _buildTag(product.discountTag!),
                      if (product.offerTag != null)
                        Padding(
                          padding: EdgeInsets.only(top: 4.h),
                          child: _buildTag(product.offerTag!),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Details Section ─────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Product Name
                Text(
                  product.name,
                  style: TextStyleManager.style11Medium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                ),
                SizedBox(height: 8.h),
                
                // Prices
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    if (product.oldPrice != null) ...[
                      Text(
                        '${product.oldPrice?.toInt()} ${'home.sar'.tr()}',
                        style: TextStyleManager.style11Medium.copyWith(
                          color: AppColors.error, // Red old price
                          decoration: TextDecoration.lineThrough,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8.w),
                    ],
                    Text(
                      '${product.currentPrice.toInt()}',
                      style: TextStyleManager.style16Bold.copyWith(
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'home.sar'.tr(),
                      style: TextStyleManager.style11Medium.copyWith(
                        color: AppColors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                
                // Add to Cart Button
                SizedBox(
                  height: 38.h,
                  child: ElevatedButton(
                    onPressed: onAddToCart ?? () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.marketGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'market.add_to_cart'.tr(),
                          style: TextStyleManager.style11Medium.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 16.sp,
                          color: AppColors.white,
                        ),
                      ],
                    ),
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

  Widget _buildTag(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.tagBackground,
        borderRadius: BorderRadiusDirectional.horizontal(start: Radius.circular(4.r)),
      ),
      child: Text(
        text,
        style: TextStyleManager.style9Medium.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
