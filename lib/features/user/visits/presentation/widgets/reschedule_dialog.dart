import 'package:fitness_day/core/widgets/app_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/user/visits/presentation/manager/change_assessment_cubit.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/generated/locale_keys.g.dart';
import 'package:fitness_day/core/widgets/errors/show_app_error.dart';

class RescheduleDialog extends StatefulWidget {
  final String assessmentId;

  const RescheduleDialog({super.key, required this.assessmentId});

  @override
  State<RescheduleDialog> createState() => _RescheduleDialogState();
}

class _RescheduleDialogState extends State<RescheduleDialog> {
  DateTime? _selectedDate;

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChangeAssessmentCubit, ChangeAssessmentState>(
      listener: (context, state) {
        if (state is ChangeAssessmentSuccess) {
          showAppSnackBar(
            context,
            text: state.message,
            isSuccess: true,
          );
          context.pop();
        } else if (state is ChangeAssessmentError) {
          showAppError(context, state.error, message: state.message);
        }
      },
      builder: (context, state) {
        bool isLoading = state is ChangeAssessmentLoading;

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.primary),
                      onPressed: () => context.pop(),
                    ),
                    Text(
                      LocaleKeys.visit_details_reschedule_title.tr(),
                      style: TextStyleManager.style16Bold,
                    ),
                    SizedBox(width: 48.w),
                  ],
                ),
                SizedBox(height: 24.h),
                InkWell(
                  onTap: _selectDate,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.borderGrey),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedDate == null
                              ? LocaleKeys.visit_details_select_new_date.tr()
                              : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                          style: TextStyleManager.style14Medium,
                        ),
                        const Icon(Icons.calendar_today, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 32.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isLoading ? null : () => context.pop(),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                        child: Text(LocaleKeys.visit_details_cancel.tr(), style: TextStyleManager.style14Medium.copyWith(color: AppColors.primary)),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: (isLoading || _selectedDate == null)
                            ? null
                            : () {
                                final isoDate = _selectedDate!.toUtc().toIso8601String();
                                context.read<ChangeAssessmentCubit>().submitChangeRequest(
                                      assessmentId: widget.assessmentId,
                                      type: 'reschedule',
                                      branchId: 'BRANCH', // Fallback or could add selector
                                      date: isoDate, 
                                    );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                        child: isLoading
                            ? SizedBox(
                                height: 20.h,
                                width: 20.h,
                                child: const CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
                              )
                            : Text(LocaleKeys.visit_details_save.tr(), style: TextStyleManager.style14Medium.copyWith(color: AppColors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
