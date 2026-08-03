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
                  // 2. Scroll Wheels Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 50.w,
                        child: ListWheelScrollView.useDelegate(
                          controller: _decimalScrollController,
                          itemExtent: 50.h,
                          physics: const FixedExtentScrollPhysics(),
                          perspective: 0.005,
                          onSelectedItemChanged: (index) {
                            setState(() {
                              _selectedDecimal = index;
                            });
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            childCount: 10,
                            builder: (context, index) {
                              final val = index;
                              final isSelected = val == _selectedDecimal;
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
                                          color: AppColors.textSecondary
                                              .withValues(alpha: 0.6),
                                        ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Text(
                        '  .  ',
                        style: TextStyleManager.heading2.copyWith(
                          color: AppColors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        width: 70.w,
                        child: ListWheelScrollView.useDelegate(
                          controller: _intScrollController,
                          itemExtent: 50.h,
                          physics: const FixedExtentScrollPhysics(),
                          perspective: 0.005,
                          onSelectedItemChanged: (index) {
                            setState(() {
                              _selectedInt = minWeight + index;
                            });
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            childCount: maxWeight - minWeight + 1,
                            builder: (context, index) {
                              final val = minWeight + index;
                              final isSelected = val == _selectedInt;
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
                                          color: AppColors.textSecondary
                                              .withValues(alpha: 0.6),
                                        ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  // 3. Left Clickable Arrow (layered on top)
                  Positioned(
                    left: 12.w,
                    child: GestureDetector(
                      onTap: () {
                        int newInt = _selectedInt;
                        int newDec = _selectedDecimal - 1;
                        if (newDec < 0) {
                          newDec = 9;
                          newInt--;
                        }
                        _animateTo(newInt, newDec);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: EdgeInsets.all(8.r),
                        child: Icon(
                          Icons.skip_next,
                          color: AppColors.primary,
                          size: 24.sp,
                        ),
                      ),
                    ),
                  ),
                  // 4. Right Clickable Arrow (layered on top)
                  Positioned(
                    right: 12.w,
                    child: GestureDetector(
                      onTap: () {
                        int newInt = _selectedInt;
                        int newDec = _selectedDecimal + 1;
                        if (newDec > 9) {
                          newDec = 0;
                          newInt++;
                        }
                        _animateTo(newInt, newDec);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: EdgeInsets.all(8.r),
                        child: Icon(
                          Icons.skip_previous,
                          color: AppColors.primary,
                          size: 24.sp,
                        ),
                      ),
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
