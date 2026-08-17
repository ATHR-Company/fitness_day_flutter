import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

class WaterOption {
  final double amount;
  final String iconAsset;

  const WaterOption({required this.amount, required this.iconAsset});
}

/// Litres, written the way a person writes them: `1 L`, `0.75 L`, `0.3 L`.
///
/// Always Latin digits and always with the leading zero. The screen used to
/// assemble the text by hand as `'.${amount * 100}'`, which dropped the leading
/// zero on every fraction — and turned a full litre into `.100 L`.
String formatLitres(double litres) {
  // Two decimals is the most any preset needs; trailing zeros are noise.
  String text = litres.toStringAsFixed(2);
  if (text.contains('.')) {
    text = text.replaceFirst(RegExp(r'0+$'), '');
    text = text.replaceFirst(RegExp(r'\.$'), '');
  }
  return text;
}

/// Dialog for picking a water quantity — used both to add and to remove.
class ManualAddSheet extends StatefulWidget {
  /// Receives the chosen amount in litres. What happens to it — added or
  /// subtracted — is the caller's decision.
  final void Function(double) onConfirm;

  /// Heading. Defaults to the "enter manually" wording of the add flow.
  final String? title;

  const ManualAddSheet({super.key, required this.onConfirm, this.title});

  @override
  State<ManualAddSheet> createState() => _ManualAddSheetState();
}

class _ManualAddSheetState extends State<ManualAddSheet> {
  // Available amounts and their icons (ordered largest to smallest).
  final List<WaterOption> _options = const [
    WaterOption(amount: 1.0, iconAsset: SvgIcons.water1L),
    WaterOption(amount: 0.75, iconAsset: SvgIcons.water75L),
    WaterOption(amount: 0.5, iconAsset: SvgIcons.water5L),
    WaterOption(amount: 0.3, iconAsset: SvgIcons.water3L),
    WaterOption(amount: 0.2, iconAsset: SvgIcons.waterGlass),
  ];

  int _selectedIndex = 3; // default 0.3 L
  late double _manualAmount;

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
                  widget.title ?? 'hydration.enter_manually'.tr(),
                  textAlign: TextAlign.center,
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
                    '${formatLitres(_manualAmount)} ${'hydration.litre_short'.tr()}',
                    style: TextStyleManager.heading2.copyWith(
                      color: AppColors.hydrationAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  // Equal slots rather than spaceEvenly: five labels at a large
                  // system font are wider than the dialog, and a Row cannot
                  // shrink children that carry no flex.
                  children: List.generate(_options.length, (index) {
                    final opt = _options[index];
                    final isSelected = _selectedIndex == index;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _selectOption(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: EdgeInsets.symmetric(horizontal: 2.w),
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color:
                                isSelected ? AppColors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.hydrationAccent
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildContainerIcon(index, isSelected),
                              SizedBox(height: 4.h),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '${formatLitres(opt.amount)} ${'hydration.litre_short'.tr()}',
                                  maxLines: 1,
                                  style: TextStyleManager.style10Medium.copyWith(
                                    color: isSelected
                                        ? AppColors.hydrationAccent
                                        : AppColors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
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
                      widget.onConfirm(_manualAmount);
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

  /// Different sizes, to visually mimic different container sizes. Ordered
  /// largest first, matching [_options].
  static const _iconHeights = [52.0, 44.0, 36.0, 30.0, 26.0];
  static const _iconWidths = [22.0, 22.0, 20.0, 20.0, 22.0];

  Widget _buildContainerIcon(int index, bool isSelected) {
    final opt = _options[index];

    // Every option reserves the same height and sits its icon at the bottom of
    // it. Without this each column was only as tall as its own icon, and the
    // Row centred them — so the labels landed at five different heights, with
    // "1 L" (tallest bottle) lowest. Bottom-aligning also reads better: the
    // containers stand on one shelf instead of floating.
    return SizedBox(
      height: _iconHeights.first.h,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: AppImage(
          opt.iconAsset,
          width: _iconWidths[index].w,
          height: _iconHeights[index].h,
          color:
              isSelected ? AppColors.hydrationAccent : AppColors.hydrationUnselected,
        ),
      ),
    );
  }
}
