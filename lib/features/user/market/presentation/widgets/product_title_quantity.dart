import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Product name on the leading side, +/- quantity stepper on the trailing side.
class ProductTitleQuantity extends StatelessWidget {
  final String name;
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const ProductTitleQuantity({
    super.key,
    required this.name,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product name
          Expanded(
            child: Text(
              name,
              style: TextStyleManager.heading3.copyWith(
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          // Quantity stepper
          Row(
            children: [
              GestureDetector(
                onTap: onIncrement,
                child: Icon(
                  Icons.add_circle_outline,
                  color: AppColors.primary,
                  size: 28.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                '$quantity',
                style: TextStyleManager.heading3.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 12.w),
              GestureDetector(
                onTap: onDecrement,
                child: Icon(
                  Icons.remove_circle_outline,
                  color: AppColors.primary,
                  size: 28.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
