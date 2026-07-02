import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/widgets/profile/profile_dialog_base.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

class EditGoalDialog extends StatefulWidget {
  final String currentGoal;
  final Function(String) onSave;

  const EditGoalDialog({
    super.key,
    required this.currentGoal,
    required this.onSave,
  });

  @override
  State<EditGoalDialog> createState() => _EditGoalDialogState();
}

class _EditGoalDialogState extends State<EditGoalDialog> {
  late String _selectedGoal;

  final List<String> _goals = [
    'login.goal_gain',
    'login.goal_lose',
    'login.goal_maintain',
  ];

  @override
  void initState() {
    super.initState();
    _selectedGoal = widget.currentGoal;
  }

  @override
  Widget build(BuildContext context) {
    return ProfileDialogBase(
      title: 'login.goal_hint'.tr(),
      onSave: () => widget.onSave(_selectedGoal),
      child: Container(
        height: 56.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2), width: 1),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _goals.contains(_selectedGoal) ? _selectedGoal : _goals.first,
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
            alignment: Alignment.centerRight,
            onChanged: (val) {
              if (val != null) {
                setState(() => _selectedGoal = val);
              }
            },
            items: _goals.map((goalKey) {
              return DropdownMenuItem<String>(
                value: goalKey,
                alignment: Alignment.centerRight,
                child: Text(
                  goalKey.tr(),
                  style: TextStyleManager.style14Medium.copyWith(
                    color: AppColors.black,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
