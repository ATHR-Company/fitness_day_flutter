import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/routes/deep_link_back.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:fitness_day/features/user/market/presentation/screens/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Top bar for the product details screen: back button, centred title,
/// and a cart shortcut on the trailing edge.
class ProductDetailsAppBar extends StatelessWidget {
  final String title;

  const ProductDetailsAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Centred title
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyleManager.heading3.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.w800,
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back button
              GestureDetector(
                onTap: () => DeepLinkBack.pop(context),
                child: _CircleBtn(
                  child: Icon(
                    Icons.arrow_back_ios_rounded,
                    size: 20.sp,
                    color: AppColors.black,
                  ),
                ),
              ),

              // Cart shortcut
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                ),
                child: _CircleBtn(
                  child: AppImage(
                    SvgIcons.market_icon,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final Widget child;

  const _CircleBtn({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44.w,
      height: 44.w,
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Center(child: child),
    );
  }
}
