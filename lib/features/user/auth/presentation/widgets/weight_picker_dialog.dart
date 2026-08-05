import 'dart:ui' as ui;

// easy_localization re-exports intl's TextDirection, which shadows Flutter's —
// hence the `ui.` prefix on every TextDirection below.
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

/// Wheel picker for weight in kilogrammes, split into a whole part and one
/// decimal. Pops the selected value as a `double`.
class WeightPickerDialog extends StatefulWidget {
  final double initialWeight;
  const WeightPickerDialog({super.key, required this.initialWeight});

  @override
  State<WeightPickerDialog> createState() => _WeightPickerDialogState();
}

class _WeightPickerDialogState extends State<WeightPickerDialog> {
  late int _selectedInt;
  late int _selectedDecimal;
  late FixedExtentScrollController _intScrollController;
  late FixedExtentScrollController _decimalScrollController;
  final int minWeight = 20;
  final int maxWeight = 200;

  @override
  void initState() {
    super.initState();
    double w = widget.initialWeight;
    if (w < minWeight || w > maxWeight) {
      w = 70.0;
    }
    _selectedInt = w.toInt();
    _selectedDecimal = ((w - _selectedInt) * 10).round().clamp(0, 9);

    _intScrollController = FixedExtentScrollController(
      initialItem: _selectedInt - minWeight,
    );
    _decimalScrollController = FixedExtentScrollController(
      initialItem: _selectedDecimal,
    );
  }

  @override
  void dispose() {
    _intScrollController.dispose();
    _decimalScrollController.dispose();
    super.dispose();
  }

  void _animateTo(int intVal, int decVal) {
    if (intVal >= minWeight && intVal <= maxWeight) {
      setState(() {
        _selectedInt = intVal;
      });
      _intScrollController.animateToItem(
        intVal - minWeight,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
    if (decVal >= 0 && decVal <= 9) {
      setState(() {
        _selectedDecimal = decVal;
      });
      _decimalScrollController.animateToItem(
        decVal,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildStepArrow({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: EdgeInsets.all(8.r),
          child: Icon(icon, color: AppColors.primary, size: 24.sp),
        ),
      ),
    );
  }

  /// One number column. Both wheels differ only in their range and the field
  /// they write to, so they share this instead of duplicating the delegate.
  Widget _buildWheel({
    required FixedExtentScrollController controller,
    required int itemCount,
    required int Function(int index) valueAt,
    required int selectedValue,
    required ValueChanged<int> onSelected,
  }) {
    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: 50.h,
      physics: const FixedExtentScrollPhysics(),
      perspective: 0.005,
      onSelectedItemChanged: (index) => onSelected(valueAt(index)),
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: itemCount,
        builder: (context, index) {
          final val = valueAt(index);
          final isSelected = val == selectedValue;
          return Container(
            height: 50.h,
            alignment: Alignment.center,
            child: Text(
              '$val',
              style: isSelected
                  ? TextStyleManager.heading2.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                    )
                  : TextStyleManager.heading3.copyWith(
                      color: AppColors.textSecondary.withValues(alpha: 0.6),
                    ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
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
          children: [
            Text(
              'auth_select_weight'.tr(),
              style: TextStyleManager.heading2.copyWith(
                color: AppColors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 32.h),
            SizedBox(
              height: 150.h,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 1. Background Highlight Bar (behind scroll views)
                  Container(
                    height: 50.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundTint,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  // 2. Scroll Wheels Row.
                  // Forced LTR: a decimal number reads whole-part-then-tenths
                  // in every language. The row used to inherit the app's
                  // direction, so in English the wheels swapped and the screen
                  // showed "5 . 70" instead of "70 . 5".
                  Directionality(
                    textDirection: ui.TextDirection.ltr,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Whole kilogrammes
                        SizedBox(
                          width: 70.w,
                          child: _buildWheel(
                            controller: _intScrollController,
                            itemCount: maxWeight - minWeight + 1,
                            valueAt: (index) => minWeight + index,
                            selectedValue: _selectedInt,
                            onSelected: (value) =>
                                setState(() => _selectedInt = value),
                          ),
                        ),
                        Text(
                          '  .  ',
                          style: TextStyleManager.heading2.copyWith(
                            color: AppColors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Tenths
                        SizedBox(
                          width: 50.w,
                          child: _buildWheel(
                            controller: _decimalScrollController,
                            itemCount: 10,
                            valueAt: (index) => index,
                            selectedValue: _selectedDecimal,
                            onSelected: (value) =>
                                setState(() => _selectedDecimal = value),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 3. Step-down arrow, on the same side as the low digits.
                  // Wrapped in LTR like the wheels: skip_next/skip_previous
                  // mirror themselves under RTL, which would point them away
                  // from the direction they actually move the value.
                  Positioned(
                    left: 12.w,
                    child: _buildStepArrow(
                      icon: Icons.skip_previous,
                      onTap: () {
                        int newInt = _selectedInt;
                        int newDec = _selectedDecimal - 1;
                        if (newDec < 0) {
                          newDec = 9;
                          newInt--;
                        }
                        _animateTo(newInt, newDec);
                      },
                    ),
                  ),
                  // 4. Step-up arrow
                  Positioned(
                    right: 12.w,
                    child: _buildStepArrow(
                      icon: Icons.skip_next,
                      onTap: () {
                        int newInt = _selectedInt;
                        int newDec = _selectedDecimal + 1;
                        if (newDec > 9) {
                          newDec = 0;
                          newInt++;
                        }
                        _animateTo(newInt, newDec);
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  elevation: 2,
                ),
                onPressed: () {
                  final finalWeight = _selectedInt + (_selectedDecimal / 10.0);
                  Navigator.pop(context, finalWeight);
                },
                child: Text(
                  'auth_save'.tr(),
                  style: TextStyleManager.style14Bold.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
