import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/widgets/profile/profile_dialog_base.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/user/auth/data/models/user_lookups_model.dart';

class EditGoalDialog extends StatefulWidget {
  final List<LookupItem> goals;
  final String? currentGoalId;
  final void Function(String goalId, String goalName) onSave;

  const EditGoalDialog({
    super.key,
    required this.goals,
    required this.currentGoalId,
    required this.onSave,
  });

  @override
  State<EditGoalDialog> createState() => _EditGoalDialogState();
}

class _EditGoalDialogState extends State<EditGoalDialog> {
  late String? _selectedGoalId;

  @override
  void initState() {
    super.initState();
    _selectedGoalId = widget.currentGoalId;
  }

  @override
  Widget build(BuildContext context) {
    final hasGoals = widget.goals.isNotEmpty;
    final selectedId = (hasGoals && widget.goals.any((g) => g.id == _selectedGoalId))
        ? _selectedGoalId
        : widget.goals.firstOrNull?.id;

    return ProfileDialogBase(
      title: 'login.goal_hint'.tr(),
      onSave: () async {
        final selected = widget.goals.where((g) => g.id == selectedId).firstOrNull;
        if (selected != null) {
          widget.onSave(selected.id, selected.name);
        }
      },
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
            value: selectedId,
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
            alignment: Alignment.centerRight,
            onChanged: (val) {
              if (val != null) {
                setState(() => _selectedGoalId = val);
              }
            },
            items: widget.goals.map((goal) {
              return DropdownMenuItem<String>(
                value: goal.id,
                alignment: Alignment.centerRight,
                child: Text(
                  goal.name,
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
