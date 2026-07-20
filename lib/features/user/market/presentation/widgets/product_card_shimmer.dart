import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:fitness_day/core/theme/app_colors.dart';

/// Skeleton placeholder that mirrors [SubscriptionPackageCard]'s layout, shown
/// while products load. Self-contained (includes its own shimmer effect) so it
/// can be dropped into any list/grid.
class ProductCardShimmer extends StatelessWidget {
  const ProductCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.divider, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.r),
                    topRight: Radius.circular(16.r),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Name
                  Container(height: 9.h, width: double.infinity, color: Colors.white),
                  SizedBox(height: 6.h),
                  Container(height: 9.h, width: 80.w, color: Colors.white),
                  SizedBox(height: 10.h),
                  // Price
                  Container(height: 12.h, width: 60.w, color: Colors.white),
                  SizedBox(height: 10.h),
                  // Button
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Container(
                      height: 32.h,
                      width: 90.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
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
}

/// A scrollable grid of [ProductCardShimmer] using the same layout as the real
/// product grids (2 columns, 0.58 aspect ratio).
class ProductsGridShimmer extends StatelessWidget {
  final int itemCount;
  final EdgeInsetsGeometry? padding;

  const ProductsGridShimmer({super.key, this.itemCount = 6, this.padding});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: padding ?? EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 40.h),
      itemCount: itemCount,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 0.58,
      ),
      itemBuilder: (_, index) => const ProductCardShimmer(),
    );
  }
}
