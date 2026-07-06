import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/custom_button.dart';

class SelectionDialog extends StatefulWidget {
  final String title;
  final List<String> options;
  final String initialValue;
  final ValueChanged<String> onSelected;

  const SelectionDialog({
    super.key,
    required this.title,
    required this.options,
    required this.initialValue,
    required this.onSelected,
  });

  @override
  State<SelectionDialog> createState() => _SelectionDialogState();
}

class _SelectionDialogState extends State<SelectionDialog> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.options.indexWhere((option) => option == widget.initialValue);
    if (_selectedIndex < 0) {
      _selectedIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyleManager.heading2.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(minWidth: 24.w, minHeight: 24.w),
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: AppColors.textSecondary,
                    size: 24.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.options.length,
                separatorBuilder: (context, index) => SizedBox(height: 8.h),
                itemBuilder: (context, index) {
                  final option = widget.options[index];
                  final isSelected = _selectedIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 14.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.backgroundTint : Colors.transparent,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        option,
                        textAlign: TextAlign.start,
                        style: TextStyleManager.heading3.copyWith(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.black.withValues(alpha: 0.7),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20.h),
            CustomButton(
              text: 'add_meal.confirm'.tr(),
              color: AppColors.primary,
              onPressed: () {
                widget.onSelected(widget.options[_selectedIndex]);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

void showSelectionDialog({
  required BuildContext context,
  required String title,
  required List<String> options,
  required String initialValue,
  required ValueChanged<String> onSelected,
}) {
  showDialog(
    context: context,
    barrierColor: AppColors.black.withValues(alpha: 0.5),
    builder: (_) => SelectionDialog(
      title: title,
      options: options,
      initialValue: initialValue,
      onSelected: onSelected,
    ),
  );
}
