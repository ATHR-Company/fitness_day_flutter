import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

class OrderSuccessDialog extends StatefulWidget {
  final VoidCallback onGoHome;

  const OrderSuccessDialog({super.key, required this.onGoHome});

  @override
  State<OrderSuccessDialog> createState() => _OrderSuccessDialogState();

  /// Show the dialog — returns when the user dismisses it.
  static Future<void> show(BuildContext context,
      {required VoidCallback onGoHome}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => OrderSuccessDialog(onGoHome: onGoHome),
    );
  }
}

class _OrderSuccessDialogState extends State<OrderSuccessDialog> {
  int _rating = 4; // default 4 stars

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Close button ──────────────────────────────────────────────
            Align(
              alignment: Alignment.topLeft,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Icon(Icons.close, size: 22.sp, color: AppColors.primary),
              ),
            ),
            SizedBox(height: 8.h),

            // ── Success icon ──────────────────────────────────────────────
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.shopping_bag_outlined,
                  color: AppColors.primary,
                  size: 36.sp,
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // ── Title ─────────────────────────────────────────────────────
            Text(
              'تم تأكيد الطلب بنجاح',
              textAlign: TextAlign.center,
              style: TextStyleManager.heading2.copyWith(
                color: AppColors.black,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 8.h),

            // ── Subtitle ──────────────────────────────────────────────────
            Text(
              'برجاء تقييم التطبيق',
              textAlign: TextAlign.center,
              style: TextStyleManager.style11Medium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 20.h),

            // ── Star rating ───────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                return GestureDetector(
                  onTap: () => setState(() => _rating = starIndex),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Icon(
                      starIndex <= _rating ? Icons.star : Icons.star_border,
                      color: const Color(0xFFFFC107),
                      size: 32.sp,
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 24.h),

            // ── Home button ───────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: widget.onGoHome,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'الصفحة الرئيسية',
                  style: TextStyleManager.style15Medium.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
