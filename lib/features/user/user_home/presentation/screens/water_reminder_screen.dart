import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/time_picker_bottom_sheet.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/hydration/reminder_option_picker_dialog.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/hydration/unsaved_changes_dialog.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/hydration/water_setting_card.dart';

/// Water drinking reminder settings screen.
class WaterReminderScreen extends StatefulWidget {
  const WaterReminderScreen({super.key});

  @override
  State<WaterReminderScreen> createState() => _WaterReminderScreenState();
}

class _WaterReminderScreenState extends State<WaterReminderScreen> {
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 8, minute: 10);
  int _intervalMinutes = 10;
  int _reminderCount = 3;
  final double _dailyGoal = 2.25;

  late TimeOfDay _originalStartTime;
  late TimeOfDay _originalEndTime;
  late int _originalIntervalMinutes;
  late int _originalReminderCount;

  @override
  void initState() {
    super.initState();
    _originalStartTime = _startTime;
    _originalEndTime = _endTime;
    _originalIntervalMinutes = _intervalMinutes;
    _originalReminderCount = _reminderCount;
  }

  bool get _hasChanges =>
      _startTime != _originalStartTime ||
      _endTime != _originalEndTime ||
      _intervalMinutes != _originalIntervalMinutes ||
      _reminderCount != _originalReminderCount;

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      barrierColor: AppColors.black.withValues(alpha: 0.4),
      builder: (_) => const UnsavedChangesDialog(),
    );

    if (result == true) {
      _originalStartTime = _startTime;
      _originalEndTime = _endTime;
      _originalIntervalMinutes = _intervalMinutes;
      _originalReminderCount = _reminderCount;
      return true;
    } else if (result == false) {
      return true;
    }
    // Dialog dismissed without a choice → stay on the screen.
    return false;
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'hydration.am'.tr() : 'hydration.pm'.tr();
    return '$hour:$minute $period';
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showModalBottomSheet<TimeOfDay>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => TimePickerBottomSheet(initialTime: isStart ? _startTime : _endTime),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _showIntervalPicker() async {
    final picked = await showDialog<int>(
      context: context,
      barrierColor: AppColors.black.withValues(alpha: 0.4),
      builder: (_) => ReminderOptionPickerDialog(
        titleKey: 'hydration.reminder_interval_label',
        options: const [5, 10, 15, 20, 30, 45, 60],
        selectedValue: _intervalMinutes,
        valueLabelKey: 'hydration.minute_value',
      ),
    );
    if (picked != null) setState(() => _intervalMinutes = picked);
  }

  Future<void> _showCountPicker() async {
    final picked = await showDialog<int>(
      context: context,
      barrierColor: AppColors.black.withValues(alpha: 0.4),
      builder: (_) => ReminderOptionPickerDialog(
        titleKey: 'hydration.reminder_count_label',
        options: const [1, 2, 3, 4, 5, 6, 7, 8],
        selectedValue: _reminderCount,
        valueLabelKey: 'hydration.times_value',
      ),
    );
    if (picked != null) setState(() => _reminderCount = picked);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Stack(
          children: [
            PositionedDirectional(
              top: 0,
              end: 0,
              child: SvgPicture.asset(
                SvgIcons.decor,
                fit: BoxFit.fill,
                color: AppColors.hydrationDarkText.withValues(alpha: 0.05),
              ),
            ),
            const PositionedDirectional(
              bottom: 0,
              start: 0,
              end: 0,
              child: _WaterBackground(),
            ),
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    child: Row(
                      children: [
                        const Spacer(),
                        Text(
                          'hydration.reminder_title'.tr(),
                          style: TextStyleManager.heading3.copyWith(
                            color: AppColors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () async {
                            final shouldPop = await _onWillPop();
                            if (shouldPop && context.mounted) Navigator.of(context).pop();
                          },
                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: 20.sp,
                            color: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40.h),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          WaterSettingCard(
                            label: 'hydration.daily_goal_label'.tr(),
                            value: '$_dailyGoal L',
                            onTap: null,
                          ),
                          SizedBox(height: 30.h),
                          Padding(
                            padding: EdgeInsetsDirectional.only(end: 4.w, bottom: 10.h),
                            child: Text(
                              'hydration.notifications_title'.tr(),
                              style: TextStyleManager.heading3.copyWith(
                                color: AppColors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ),
                          WaterSettingCard(
                            label: 'hydration.reminder_start_label'.tr(),
                            value: _formatTime(_startTime),
                            onTap: () => _pickTime(isStart: true),
                          ),
                          SizedBox(height: 8.h),
                          WaterSettingCard(
                            label: 'hydration.reminder_end_label'.tr(),
                            value: _formatTime(_endTime),
                            onTap: () => _pickTime(isStart: false),
                          ),
                          SizedBox(height: 8.h),
                          WaterSettingCard(
                            label: 'hydration.reminder_interval_label'.tr(),
                            value: 'hydration.minutes_value'.tr(args: ['$_intervalMinutes']),
                            onTap: _showIntervalPicker,
                          ),
                          SizedBox(height: 8.h),
                          WaterSettingCard(
                            label: 'hydration.reminder_count_label'.tr(),
                            value: 'hydration.times_value'.tr(args: ['$_reminderCount']),
                            onTap: _showCountPicker,
                          ),
                          SizedBox(height: 20.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WaterBackground extends StatelessWidget {
  const _WaterBackground();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(SvgIcons.WaterBG, fit: BoxFit.cover);
  }
}
