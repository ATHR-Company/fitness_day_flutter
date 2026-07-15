import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/custom_outlined_button.dart';
import 'package:fitness_day/core/widgets/custom_button.dart';
import 'package:fitness_day/core/widgets/date_picker_bottom_sheet.dart';
import 'package:fitness_day/core/widgets/time_picker_bottom_sheet.dart';
import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart' hide DateFormat;
import 'package:intl/intl.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/features/user/visits/presentation/manager/change_assessment_cubit.dart';
import 'package:fitness_day/core/widgets/app_snack_bar.dart';
import '../../../../../core/constant/app_assets.dart';

class RescheduleVisitDialog extends StatefulWidget {
  final String assessmentId;
  const RescheduleVisitDialog({super.key, required this.assessmentId});

  @override
  State<RescheduleVisitDialog> createState() => _RescheduleVisitDialogState();
}

class _RescheduleVisitDialogState extends State<RescheduleVisitDialog> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  Widget build(BuildContext context) {
    // Format date and time
    String dateText = 'visit_details.select_date'.tr();
    if (_selectedDate != null) {
      final dateFormat = DateFormat(
        'EEEE d/ M / yyyy',
        context.locale.languageCode,
      );
      dateText = dateFormat.format(_selectedDate!);
    }

    String timeText = 'visit_details.select_time'.tr();
    if (_selectedTime != null) {
      final now = DateTime.now();
      final dt = DateTime(
        now.year,
        now.month,
        now.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
      final timeFormat = DateFormat('hh:mm a', context.locale.languageCode);
      timeText = timeFormat.format(dt);
    }

    return BlocProvider(
      create: (context) => getIt<ChangeAssessmentCubit>(),
      child: BlocConsumer<ChangeAssessmentCubit, ChangeAssessmentState>(
        listener: (context, state) {
          if (state is ChangeAssessmentSuccess) {
            showAppSnackBar(
              context,
              text: 'تم تعديل الميعاد بنجاح',
              isSuccess: true,
            );
            Navigator.of(context).pop();
          } else if (state is ChangeAssessmentError) {
            showAppSnackBar(
              context,
              text: state.message,
              isError: true,
            );
          }
        },
        builder: (context, state) {
          bool isLoading = state is ChangeAssessmentLoading;
          
          return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 24.w),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.lightGreenBackground, AppColors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(32.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'visit_details.reschedule_title'.tr(),
                          style: TextStyleManager.heading3.copyWith(
                            color: AppColors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Icon(
                          Icons.close,
                          color: AppColors.primary,
                          size: 28.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32.h),

                  // Date Field
                  GestureDetector(
                    onTap: () async {
                      final date = await showModalBottomSheet<DateTime>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) =>
                            DatePickerBottomSheet(initialDate: _selectedDate),
                      );
                      if (date != null) {
                        setState(() => _selectedDate = date);
                      }
                    },
                    child: _buildField(icon: SvgIcons.calendar, text: dateText),
                  ),

                  SizedBox(height: 16.h),

                  // Time Field
                  GestureDetector(
                    onTap: () async {
                      final time = await showModalBottomSheet<TimeOfDay>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) =>
                            TimePickerBottomSheet(initialTime: _selectedTime),
                      );
                      if (time != null) {
                        setState(() => _selectedTime = time);
                      }
                    },
                    child: _buildField(icon: SvgIcons.clock, text: timeText),
                  ),

                  SizedBox(height: 32.h),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: CustomOutlinedButton(
                          text: 'visit_details.cancel'.tr(),
                          onPressed: isLoading ? () {} : () => Navigator.of(context).pop(),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: CustomButton(
                          isLoading: isLoading,
                          text: 'visit_details.save'.tr(),
                          onPressed: isLoading
                              ? () {}
                              : () {
                                  if (_selectedDate != null && _selectedTime != null) {
                                    final DateTime newDate = DateTime(
                                      _selectedDate!.year,
                                      _selectedDate!.month,
                                      _selectedDate!.day,
                                      _selectedTime!.hour,
                                      _selectedTime!.minute,
                                    );
                                    context.read<ChangeAssessmentCubit>().submitChangeRequest(
                                      assessmentId: widget.assessmentId,
                                      date: newDate.toUtc().toIso8601String(),
                                    );
                                  } else {
                                    showAppSnackBar(
                                      context,
                                      text: 'يرجى اختيار التاريخ والوقت',
                                      isError: true,
                                    );
                                  }
                                },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildField({required String icon, required String text}) {
    return Container(
      height: 56.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: AppImage(icon),
          ),
          Container(
            height: 24.h,
            width: 1.5.w,
            color: AppColors.primary.withValues(alpha: 0.5),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                text,
                textAlign: TextAlign.right,
                textDirection: ui.TextDirection.rtl,
                style: TextStyleManager.style11Medium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Function to show the dialog
void showRescheduleDialog(BuildContext context, String assessmentId) {
  showDialog(
    context: context,
    barrierColor: AppColors.scrimOverlay.withValues(alpha: 0.5),
    builder: (context) => RescheduleVisitDialog(assessmentId: assessmentId),
  );
}
