import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

class WaterOption {
  final double amount;
  final String label;
  final String iconAsset;

  const WaterOption({
    required this.amount,
    required this.label,
    required this.iconAsset,
  });
}

/// Bottom-sheet dialog for manually entering a water quantity.
class ManualAddSheet extends StatefulWidget {
  final void Function(double) onAdd;

  const ManualAddSheet({super.key, required this.onAdd});

  @override
  State<ManualAddSheet> createState() => _ManualAddSheetState();
}

class _ManualAddSheetState extends State<ManualAddSheet> {
  // Available amounts and their icons (ordered largest to smallest).
  final List<WaterOption> _options = const [
    WaterOption(amount: 1.0, label: '1 L', iconAsset: SvgIcons.water1L),
    WaterOption(amount: 0.75, label: '.75 L', iconAsset: SvgIcons.water75L),
    WaterOption(amount: 0.5, label: '.5 L', iconAsset: SvgIcons.water5L),
    WaterOption(amount: 0.3, label: '.3 L', iconAsset: SvgIcons.water3L),
    WaterOption(amount: 0.2, label: '.2 L', iconAsset: SvgIcons.waterGlass),
  ];

  int _selectedIndex = 3; // default .3 L
  double _manualAmount = 0.25;

  @override
  void initState() {
    super.initState();
    _manualAmount = _options[_selectedIndex].amount;
  }

  void _selectOption(int index) {
    setState(() {
      _selectedIndex = index;
      _manualAmount = _options[index].amount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.hydrationAccent.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 40.h),
                AppImage(SvgIcons.water_bg, width: 60.w, height: 80.h),
                SizedBox(height: 12.h),
                Text(
                  'hydration.enter_manually'.tr(),
                  style: TextStyleManager.heading3.copyWith(
                    color: AppColors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.hydrationAccent.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                  ),
                  child: Text(
                    '.${(_manualAmount * 100).toStringAsFixed(0)} L',
                    style: TextStyleManager.heading2.copyWith(
                      color: AppColors.hydrationAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(_options.length, (index) {
                    final opt = _options[index];
                    final isSelected = _selectedIndex == index;
                    return GestureDetector(
                      onTap: () => _selectOption(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: isSelected ? AppColors.hydrationAccent : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildContainerIcon(index, isSelected),
                            SizedBox(height: 4.h),
                            Text(
                              opt.label,
                              style: TextStyleManager.style10Medium.copyWith(
                                color: isSelected ? AppColors.hydrationAccent : AppColors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(height: 24.h),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onAdd(_manualAmount);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.hydrationProgressTrack,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
                      elevation: 0,
                    ),
                    child: Text(
                      'hydration.save'.tr(),
                      style: TextStyleManager.heading3.copyWith(
                        color: AppColors.hydrationDarkText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
              ],
            ),
          ),
        ),
        PositionedDirectional(
          end: 0,
          top: 0,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Padding(
              padding: EdgeInsets.all(10.r),
              child: Container(
                width: 40.w,
                height: 40.w,
                decoration: const BoxDecoration(
                  color: AppColors.hydrationAccent,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, color: AppColors.white, size: 20.sp),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContainerIcon(int index, bool isSelected) {
    // Different sizes to visually mimic different container sizes.
    const heights = [52.0, 44.0, 36.0, 30.0, 26.0];
    const widths = [22.0, 22.0, 20.0, 20.0, 22.0];
    final opt = _options[index];

    return AppImage(
      opt.iconAsset,
      width: widths[index].w,
      height: heights[index].h,
      color: isSelected ? AppColors.hydrationAccent : AppColors.hydrationUnselected,
    );
  }
}
