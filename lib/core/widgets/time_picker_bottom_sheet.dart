import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_bottom_sheet.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';

// ألوان صفحة الهايدريشن
const _kWaterCyan = Color(0xFF23C4D7);
const _kWaterLight = Color(0xFFDAF6FF);
const _kWaterLighter = Color(0xFFF0FBFF);

class TimePickerBottomSheet extends StatefulWidget {
  final TimeOfDay? initialTime;

  const TimePickerBottomSheet({super.key, this.initialTime});

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

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      title: 'visit_details.select_time'.tr(),
      closeIconColor: _kWaterCyan,
      confirmColor: _kWaterCyan,
      backgroundGradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_kWaterLighter, AppColors.white],
      ),
      onConfirm: () {
        Navigator.of(context).pop(TimeOfDay.fromDateTime(_selectedTime));
      },
      child: SizedBox(
        height: 200.h,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // حاوية التحديد بلون الهايدريشن
            Container(
              height: 56.h,
              decoration: BoxDecoration(
                color: _kWaterLight,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: _kWaterCyan.withValues(alpha: 0.3),
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
                  color: _kWaterCyan,
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
