import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Current price with an optional strikethrough old price beside it.
class ProductPriceLabel extends StatelessWidget {
  final double price;
  final double? oldPrice;

  const ProductPriceLabel({
    super.key,
    required this.price,
    this.oldPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            '${price.toInt()}',
            style: TextStyleManager.heading1.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            'home.sar'.tr(),
            style: TextStyleManager.style13Medium.copyWith(
              color: AppColors.black,
            ),
          ),
          if (oldPrice != null) ...[
            SizedBox(width: 12.w),
            Text(
              '${oldPrice!.toInt()} ${'home.sar'.tr()}',
              style: TextStyleManager.style11Medium.copyWith(
                color: AppColors.error,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
