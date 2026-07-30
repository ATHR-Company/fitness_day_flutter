import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

/// Wheel picker for height in centimetres. Pops the selected value as an `int`.
class HeightPickerDialog extends StatefulWidget {
  final int initialHeight;
  const HeightPickerDialog({super.key, required this.initialHeight});

  @override
  State<HeightPickerDialog> createState() => _HeightPickerDialogState();
}

class _HeightPickerDialogState extends State<HeightPickerDialog> {
  late int _selectedHeight;
  late FixedExtentScrollController _scrollController;
  final int minHeight = 50;
  final int maxHeight = 280;

  @override
  void initState() {
    super.initState();
    int initial = widget.initialHeight;
    if (initial < minHeight || initial > maxHeight) {
      initial = 170;
    }
    _selectedHeight = initial;
    _scrollController = FixedExtentScrollController(
      initialItem: _selectedHeight - minHeight,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _animateTo(int val) {
    if (val >= minHeight && val <= maxHeight) {
      setState(() {
        _selectedHeight = val;
      });
      _scrollController.animateToItem(
        val - minHeight,
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
              'auth_select_height'.tr(),
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
                  // 1. Background Highlight Bar (behind scroll view)
                  Container(
                    height: 50.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundTint,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  // 2. Scroll View
                  ListWheelScrollView.useDelegate(
                    controller: _scrollController,
                    itemExtent: 50.h,
                    physics: const FixedExtentScrollPhysics(),
                    perspective: 0.005,
                    onSelectedItemChanged: (index) {
                      setState(() {
                        _selectedHeight = minHeight + index;
                      });
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: maxHeight - minHeight + 1,
                      builder: (context, index) {
                        final val = minHeight + index;
                        final isSelected = val == _selectedHeight;
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
                                    color: AppColors.textSecondary.withValues(
                                      alpha: 0.6,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                  // 3. Left Clickable Arrow (layered on top)
                  Positioned(
                    left: 12.w,
                    child: GestureDetector(
                      onTap: () => _animateTo(_selectedHeight - 1),
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
                      onTap: () => _animateTo(_selectedHeight + 1),
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
                  Navigator.pop(context, _selectedHeight);
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
