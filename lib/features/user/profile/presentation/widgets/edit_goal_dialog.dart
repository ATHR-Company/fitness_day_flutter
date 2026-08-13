import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/widgets/profile/profile_dialog_base.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/user/auth/data/models/user_lookups_model.dart';

/// Goal picker for the personal profile.
///
/// The options are listed inline rather than behind a [DropdownButton]: that
/// widget anchors its menu so the *selected* row lands on top of the button, so
/// the list appeared in a different place depending on what was already chosen.
/// With the rows in the dialog there is no menu to place at all.
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
      child: ConstrainedBox(
        // A longer lookup list scrolls inside the dialog instead of pushing the
        // save buttons off screen.
        constraints: BoxConstraints(maxHeight: 0.5.sh),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < widget.goals.length; i++) ...[
                if (i > 0) SizedBox(height: 12.h),
                _GoalOption(
                  label: widget.goals[i].name,
                  isSelected: widget.goals[i].id == selectedId,
                  onTap: () =>
                      setState(() => _selectedGoalId = widget.goals[i].id),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// One selectable row — tinted and outlined in the brand green when picked.
class _GoalOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GoalOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.backgroundTint : AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.divider.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyleManager.style13Medium.copyWith(
                  color: isSelected ? AppColors.black : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primary : AppColors.divider,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}
