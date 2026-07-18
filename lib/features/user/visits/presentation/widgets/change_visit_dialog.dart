import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/user/visits/presentation/manager/change_assessment_cubit.dart';
import 'package:fitness_day/features/user/visits/presentation/widgets/change_location_dialog.dart';
import 'package:fitness_day/core/widgets/reschedule_visit_dialog.dart';
import 'package:go_router/go_router.dart';

/// Shows a popup asking the user whether they want to change
/// the visit location or reschedule the date.
void showChangeVisitDialog(BuildContext context, String assessmentId) {
  showDialog(
    context: context,
    builder: (_) => BlocProvider(
      create: (_) => getIt<ChangeAssessmentCubit>(),
      child: _ChangeVisitTypeDialog(assessmentId: assessmentId),
    ),
  );
}

class _ChangeVisitTypeDialog extends StatelessWidget {
  final String assessmentId;
  const _ChangeVisitTypeDialog({required this.assessmentId});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      backgroundColor: AppColors.white,
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.primary),
                  onPressed: () => context.pop(),
                ),
                Expanded(
                  child: Text(
                    'visit_details.reschedule'.tr(),
                    style: TextStyleManager.style16Bold,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(width: 48.w),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              'visit_details.what_to_change'.tr(),
              style: TextStyleManager.style14Medium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),

            // Change visit location button styled like the time button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  context.pop();
                  showDialog(
                    context: context,
                    builder: (_) => BlocProvider(
                      create: (_) => getIt<ChangeAssessmentCubit>(),
                      child: ChangeLocationDialog(assessmentId: assessmentId),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColors.white,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: 14.h,
                    horizontal: 16.w,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 8.w),
                    Flexible(
                      child: Text(
                        'visit_details.change_visit_location'.tr(),
                        style: TextStyleManager.style14Medium.copyWith(
                          color: AppColors.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.h),

            // Reschedule date button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  context.pop();
                  showDialog(
                    context: context,
                    builder: (_) =>  RescheduleVisitDialog(assessmentId: assessmentId,),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: 14.h,
                    horizontal: 16.w,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 8.w),
                    Flexible(
                      child: Text(
                        'visit_details.request_change_time'.tr(),
                        style: TextStyleManager.style14Medium.copyWith(
                          color: AppColors.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
