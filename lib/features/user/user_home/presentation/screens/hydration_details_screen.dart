 import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../../../core/constant/app_assets.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class HydrationDetailsScreen extends StatefulWidget {
  const HydrationDetailsScreen({super.key});

  @override
  State<HydrationDetailsScreen> createState() => _HydrationDetailsScreenState();
}

class _HydrationDetailsScreenState extends State<HydrationDetailsScreen> {
  double currentWater = 0.000;
  final double goalWater = 2.25;

  void addWater(double amount) {
    setState(() {
      currentWater += amount;
      if (currentWater > goalWater) {
        currentWater = goalWater;
      }
    });
  }

  void removeWater(double amount) {
    setState(() {
      currentWater -= amount;
      if (currentWater < 0) {
        currentWater = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double percent = currentWater / goalWater;
    if (percent > 1.0) percent = 1.0;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          // Top right decor
          Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: SvgPicture.asset(SvgIcons.WaterBG, fit: BoxFit.cover),
          ),

          // // Bottom wave
          // Positioned(
          //   top: 10,

          //   child:
          // ),
          SafeArea(
            child: Column(
              children: [
                // AppBar
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 10.h,
                  ),
                  child: Row(
                    children: [
                      const Spacer(),
                      Text(
                        'شرب الماء', // 'Drink Water'
                        style: TextStyleManager.heading3.copyWith(
                          color: AppColors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),

                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 20.sp,
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40.h),

                // Main Circular Indicator
                // Main Circular Indicator
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    // الدايرة أول حاجة في الليستة (يعني تحت)
                    IgnorePointer(
                      child: CircularPercentIndicator(
                        radius: 120.r,
                        lineWidth: 10.w,
                        percent: percent,
                        circularStrokeCap: CircularStrokeCap.round,
                        backgroundColor: AppColors.inactiveGray.withOpacity(
                          0.2,
                        ),
                        progressColor: const Color(0xFF23C4D7),
                        center: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              SvgIcons.water_wave,
                              width: 30.w,
                              fit: BoxFit.cover,
                            ),
                            SizedBox(height: 25.h),
                            Text(
                              currentWater.toStringAsFixed(3),
                              style: TextStyleManager.heading1.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.black,
                              ),
                            ),
                            SizedBox(height: 5.h),
                            Text(
                              'L $goalWater  /',
                              style: TextStyleManager.style10Medium.copyWith(
                                color: AppColors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // الزرار آخر حاجة في الليستة (يعني فوق) — كده بيتشاف كامل وبيستقبل اللمس
                    Positioned(
                      bottom: -20.h,
                      left: 0,
                      right: 0,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: _buildActionButton(
                          iconWidget: SvgPicture.asset(
                            SvgIcons.waterGlass,
                            width: 40.w,
                            height: 40.h,
                          ),
                          label: '1 L',
                          onTap: () => addWater(1.0),
                          isFilled: true,
                          size: 80.w,
                        ),
                      ),
                    ),
                  ],
                ),
                // SizedBox(height: 20.h),

                // Action Buttons
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.w),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 40.h),
                            child: _buildActionButton(
                              iconWidget: SvgPicture.asset(
                                SvgIcons.WarterAdd,
                                width: 30.w,
                                height: 30.w,
                                fit: BoxFit.contain,
                              ),
                              label: 'يدوي',
                              onTap: () => addWater(0.25),
                              isFilled: true,
                              size: 80.w, // It has a light blue fill in Figma
                            ),
                          ),
                          // Reminder Button
                          Padding(
                            padding: EdgeInsets.only(top: 40.h),
                            child: _buildActionButton(
                              iconWidget: SvgPicture.asset(
                                SvgIcons.WaterClock,
                                width: 30.w,
                                height: 30.w,
                                fit: BoxFit.contain,
                              ),
                              label: '12:15صباحا',
                              onTap: () {},
                              isOutlined: true,
                              size: 80.w,
                            ),
                          ),

                          // Manual Add Button
                        ],
                      ),

                      // 1L Add Button (Center)
                    ],
                  ),
                ),

                const Spacer(),

                // Minus Button
                Padding(
                  padding: EdgeInsets.only(bottom: 50.h, right: 30.w),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => removeWater(0.25),
                      child: Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: const BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.remove,
                          color: const Color(0xFF23C4D7),
                          size: 24.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    IconData? icon,
    Widget? iconWidget,
    required String label,
    required VoidCallback onTap,
    bool isFilled = false,
    bool isOutlined = false,
    double? size,
  }) {
    final buttonSize = size ?? 60.w; // رجّعناها هنا

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: buttonSize, // ثبّتنا العرض
        height: buttonSize, // ثبّتنا الارتفاع
        decoration: BoxDecoration(
          color: const Color(0xFFDAF6FF),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFC9F2FF), width: 1.5),
          boxShadow: isFilled || isOutlined
              ? [
                  BoxShadow(
                    color: const Color(0xFF23C4D7).withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              iconWidget ??
                  (icon != null
                      ? Icon(icon, color: const Color(0xFF23C4D7), size: 18.sp)
                      : SvgPicture.asset(
                          SvgIcons.WarterAdd,
                          width: buttonSize * 0.4,
                          fit: BoxFit.contain,
                        )),
              SizedBox(height: 2.h),
              Text(
                label,
                style: TextStyleManager.style11Medium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 9.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
