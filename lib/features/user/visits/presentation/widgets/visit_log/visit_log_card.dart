import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:fitness_day/features/user/visits/data/models/assessment_model.dart';
import 'package:fitness_day/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Card summarizing a single visit/assessment for a selected day,
/// with optional reschedule and details actions.
class VisitLogCard extends StatelessWidget {
  final AssessmentModel assessment;
  final VoidCallback? onDetailsPressed;
  final VoidCallback onReschedulePressed;

  const VisitLogCard({
    super.key,
    required this.assessment,
    required this.onDetailsPressed,
    required this.onReschedulePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(4.r),
          topEnd: Radius.circular(4.r),
          bottomEnd: Radius.circular(4.r),
          bottomStart: Radius.circular(32.r),
        ),
        border: Border.all(color: AppColors.greenMint, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppImage(
                  assessment.image.isNotEmpty
                      ? assessment.image
                      : SvgIcons.monitor,
                  width: 44.w,
                  height: 44.w,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assessment.name,
                        style: TextStyleManager.heading3.copyWith(
                          color: AppColors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        assessment.description,
                        style: TextStyleManager.style9Medium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            SizedBox(height: 12.h),

            // ── Details ───────────────────────────────────────────────
            _row(LocaleKeys.visits_client_name_label.tr(), assessment.specialistName),
            SizedBox(height: 6.h),
            _row(
              LocaleKeys.visits_visit_time_label.tr(),
              DateFormat('yyyy-MM-dd hh:mm a', context.locale.languageCode)
                  .format(assessment.appointment),
            ),
            SizedBox(height: 6.h),
            _row(LocaleKeys.visits_visit_location_label.tr(), assessment.placement),
            SizedBox(height: 18.h),

            // ── Action buttons ────────────────────────────────────────
            if (assessment.canChangePlaceOrTime || onDetailsPressed != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Reschedule button
                  if (assessment.canChangePlaceOrTime)
                    OutlinedButton(
                      onPressed: onReschedulePressed,
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(100.w, 38.h),
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                      ),
                      child: Text(
                        LocaleKeys.visit_details_reschedule.tr(),
                        style: TextStyleManager.style12Regular.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  if (assessment.canChangePlaceOrTime && onDetailsPressed != null)
                    SizedBox(width: 10.w),

                  // Details button
                  if (onDetailsPressed != null)
                    ElevatedButton(
                      onPressed: onDetailsPressed,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(100.w, 38.h),
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        elevation: 0,
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            LocaleKeys.home_details_button.tr(),
                            style: TextStyleManager.style12Regular.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Icon(
                            Directionality.of(context) == ui.TextDirection.rtl
                                ? Icons.keyboard_double_arrow_left_rounded
                                : Icons.keyboard_double_arrow_right_rounded,
                            size: 16.sp,
                            color: AppColors.white,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyleManager.style9Medium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Text(
              value,
              style: TextStyleManager.style9Medium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
}
