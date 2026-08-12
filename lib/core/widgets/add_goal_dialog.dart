import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/custom_outlined_button.dart';
import 'package:fitness_day/core/widgets/custom_button.dart';
import 'package:easy_localization/easy_localization.dart';

class AddGoalDialog extends StatefulWidget {
  final String initialGoal;

  /// Saves the goal. Return `null` when it went through — the dialog then
  /// closes. Any other string is pinned under the field and the dialog stays
  /// open with the text still in it, so the rejection is read next to what
  /// caused it instead of as a banner over the screen the user just left.
  final Future<String?> Function(String) onSave;

  const AddGoalDialog({
    super.key,
    required this.initialGoal,
    required this.onSave,
  });

  @override
  State<AddGoalDialog> createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends State<AddGoalDialog> {
  late final TextEditingController _goalController;

  String? _errorText;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _goalController = TextEditingController(text: widget.initialGoal);
    // Typing clears whatever message is pinned under the field.
    _goalController.addListener(() {
      if (_errorText != null && mounted) setState(() => _errorText = null);
    });
  }

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final String goal = _goalController.text.trim();

    // Caught here rather than at the server: an empty goal is something this
    // screen already knows is wrong, and there is no reason to round-trip.
    if (goal.isEmpty) {
      setState(() => _errorText = 'visit_details.field_required'.tr());
      return;
    }

    setState(() {
      _isSaving = true;
      _errorText = null;
    });

    final String? error = await widget.onSave(goal);
    if (!mounted) return;

    if (error != null) {
      setState(() {
        _isSaving = false;
        _errorText = error;
      });
      return;
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'visit_details.add_goal_dialog_title'.tr(),
                    style: TextStyleManager.heading3.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                    ),
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
            SizedBox(height: 24.h),

            // Input Field Label
            Text(
              'visit_details.goal_label'.tr(),
              style: TextStyleManager.style11Medium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.start,
            ),
            SizedBox(height: 8.h),

            // Text Field Container
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: _errorText != null
                      ? AppColors.error
                      : Colors.grey.withValues(alpha: 0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _goalController,
                maxLines: 4,
                textAlign: TextAlign.start,
                style: TextStyleManager.style11Medium.copyWith(
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'visit_details.enter_goal_placeholder'.tr(),
                  hintStyle: TextStyleManager.style11Medium.copyWith(
                    color: Colors.grey.withValues(alpha: 0.5),
                  ),
                  contentPadding: EdgeInsets.all(16.w),
                  border: InputBorder.none,
                ),
              ),
            ),

            if (_errorText != null) ...[
              SizedBox(height: 8.h),
              Text(
                _errorText!,
                style: TextStyleManager.style10Medium.copyWith(
                  color: AppColors.error,
                ),
                textAlign: TextAlign.start,
              ),
            ],

            SizedBox(height: 32.h),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: CustomOutlinedButton(
                    text: 'visit_details.cancel'.tr(),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: CustomButton(
                    text: 'visit_details.save'.tr(),
                    isLoading: _isSaving,
                    onPressed: _save,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// [onSave] returns `null` on success, or the message to pin under the field.
void showAddGoalDialog({
  required BuildContext context,
  required String initialGoal,
  required Future<String?> Function(String) onSave,
}) {
  showDialog(
    context: context,
    barrierColor: AppColors.scrimOverlay.withValues(alpha: 0.5),
    // The dialog owns when it closes now — tapping outside must not discard a
    // save that is already in flight.
    barrierDismissible: false,
    builder: (context) => AddGoalDialog(
      initialGoal: initialGoal,
      onSave: onSave,
    ),
  );
}
