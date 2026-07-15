import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_bottom_sheet.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';

class TimePickerBottomSheet extends StatefulWidget {
  final TimeOfDay? initialTime;
  final Color? primaryColor;
  final Color? highlightBackgroundColor;
  final LinearGradient? backgroundGradient;

  const TimePickerBottomSheet({
    super.key, 
    this.initialTime,
    this.primaryColor,
    this.highlightBackgroundColor,
    this.backgroundGradient,
  });

  @override
  State<TimePickerBottomSheet> createState() => _TimePickerBottomSheetState();
}

class _TimePickerBottomSheetState extends State<TimePickerBottomSheet> {
  late DateTime _selectedTime;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    if (widget.initialTime != null) {
      _selectedTime = DateTime(
        now.year,
        now.month,
        now.day,
        widget.initialTime!.hour,
        widget.initialTime!.minute,
      );
    } else {
      _selectedTime = now;
    }
  }

  Color get _primaryColor => widget.primaryColor ?? AppColors.primary;
  Color get _highlightBgColor => widget.highlightBackgroundColor ?? AppColors.lightGreenBackground2;
  LinearGradient get _bgGradient => widget.backgroundGradient ?? const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.lightGreenBackground, AppColors.white],
      );

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      title: 'visit_details.select_time'.tr(),
      closeIconColor: _primaryColor,
      confirmColor: _primaryColor,
      backgroundGradient: _bgGradient,
      onConfirm: () {
        Navigator.of(context).pop(TimeOfDay.fromDateTime(_selectedTime));
      },
      child: SizedBox(
        height: 200.h,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // حاوية التحديد
            Container(
              height: 56.h,
              decoration: BoxDecoration(
                color: _highlightBgColor,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: _primaryColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
            ),

            Localizations.override(
              context: context,
              locale: const Locale('en', 'US'),
              child: TimePickerSpinner(
                time: _selectedTime,
                is24HourMode: false,
                normalTextStyle: TextStyleManager.heading2.copyWith(
                  color: AppColors.textSecondary.withValues(alpha: 0.4),
                  fontSize: 20.sp,
                ),
                highlightedTextStyle: TextStyleManager.heading2.copyWith(
                  color: _primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 24.sp,
                ),
                spacing: 30.w,
                itemHeight: 56.h,
                isForce2Digits: true,
                onTimeChange: (time) {
                  setState(() {
                    _selectedTime = time;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
