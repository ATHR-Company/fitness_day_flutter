import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/custom_button.dart';
import 'package:easy_localization/easy_localization.dart';

class AppBottomSheet extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onConfirm;
  final String? confirmText;
  final Color? closeIconColor;

  const AppBottomSheet({
    super.key,
    required this.title,
    required this.child,
    this.onConfirm,
    this.confirmText,
    this.closeIconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient, // Matches the light green to white gradient
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, MediaQuery.of(context).padding.bottom + 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyleManager.heading2.copyWith(
                  color: AppColors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Icon(
                  Icons.close,
                  color: closeIconColor ?? AppColors.black,
                  size: 24.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          
          // Content
          child,
          
          if (onConfirm != null) ...[
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: confirmText ?? 'visit_details.confirm'.tr(),
                onPressed: onConfirm!,
              ),
            ),
          ]
        ],
      ),
    );
  }
}
