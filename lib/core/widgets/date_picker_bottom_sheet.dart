import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_bottom_sheet.dart';
import 'package:easy_localization/easy_localization.dart' hide DateFormat;
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fitness_day/core/constant/app_assets.dart';

class DatePickerBottomSheet extends StatefulWidget {
  final DateTime? initialDate;

  const DatePickerBottomSheet({super.key, this.initialDate});

  @override
  State<DatePickerBottomSheet> createState() => _DatePickerBottomSheetState();
}

class _DatePickerBottomSheetState extends State<DatePickerBottomSheet> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.initialDate ?? DateTime.now();
    _focusedDay = _selectedDay;
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      title: 'visit_details.select_date'.tr(),
      closeIconColor: AppColors.primary,
      onConfirm: () {
        Navigator.of(context).pop(_selectedDay);
      },
      child: Column(
        children: [
          _buildCustomHeader(),
          SizedBox(height: 16.h),
          TableCalendar(
            locale: context.locale.languageCode,
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2050, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
            },
            headerVisible: false,
            availableGestures: AvailableGestures.horizontalSwipe,
            daysOfWeekHeight: 32.h,
            calendarStyle: CalendarStyle(
              selectedDecoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: TextStyleManager.style11Medium.copyWith(color: AppColors.white),
              todayDecoration: const BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
              ),
              todayTextStyle: TextStyleManager.style11Medium.copyWith(color: AppColors.black, fontWeight: FontWeight.bold),
              defaultTextStyle: TextStyleManager.style11Medium.copyWith(color: AppColors.textSecondary),
              weekendTextStyle: TextStyleManager.style11Medium.copyWith(color: AppColors.textSecondary),
              outsideDaysVisible: true,
              outsideTextStyle: TextStyleManager.style11Medium.copyWith(color: AppColors.divider),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyleManager.style9Medium.copyWith(color: AppColors.divider),
              weekendStyle: TextStyleManager.style9Medium.copyWith(color: AppColors.divider),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomHeader() {
    // using easy_localization's DateFormat directly
    final monthFormat = DateFormat.yMMMM(context.locale.languageCode);
    final formattedDate = monthFormat.format(_focusedDay);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left side: arrows
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
                });
              },
              child: Icon(Icons.chevron_left, color: AppColors.primary, size: 24.sp),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: () {
                setState(() {
                  _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
                });
              },
              child: Icon(Icons.chevron_right, color: AppColors.primary, size: 24.sp),
            ),
          ],
        ),
        
        // Right side: Date + Icon
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formattedDate,
              style: TextStyleManager.heading3.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8.w),
            SvgPicture.asset(
              SvgIcons.calendar,
              width: 20.sp,
              height: 20.sp,
              colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
            ),
          ],
        ),
      ],
    );
  }
}
