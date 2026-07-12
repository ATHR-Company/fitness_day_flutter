import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/widgets/screen_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/user/user_home/presentation/screens/water_reminder_screen.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/hydration/manual_add_sheet.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/hydration/water_action_button.dart';

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
      if (currentWater > goalWater) currentWater = goalWater;
    });
  }

  void removeWater(double amount) {
    setState(() {
      currentWater -= amount;
      if (currentWater < 0) currentWater = 0;
    });
  }

  void _showManualAddSheet() {
    showDialog(
      context: context,
      barrierColor: AppColors.black.withValues(alpha: 0.4),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
        child: ManualAddSheet(onAdd: addWater),
      ),
    );
  }

  void _showWaterReminderScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WaterReminderScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    double percent = currentWater / goalWater;
    if (percent > 1.0) percent = 1.0;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: ScreenBackground(
        child: Stack(
          children: [
            PositionedDirectional(
              top: 0,
              end: 0,
              child: SvgPicture.asset(
                SvgIcons.decor,
                fit: BoxFit.fill,
                color: AppColors.hydrationDarkText.withValues(alpha: 0.05),
              ),
            ),
            PositionedDirectional(
              bottom: 0,
              end: 0,
              start: 0,
              child: SvgPicture.asset(SvgIcons.WaterBG, fit: BoxFit.cover),
            ),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    child: Row(
                      children: [
                        const Spacer(),
                        Text(
                          'hydration.title'.tr(),
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

                  // Main circular indicator
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      IgnorePointer(
                        child: CircularPercentIndicator(
                          radius: 120.r,
                          lineWidth: 10.w,
                          percent: percent,
                          backgroundColor: AppColors.inactiveGray.withValues(alpha: 0.2),
                          progressColor: AppColors.hydrationAccent,
                          center: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(SvgIcons.water_wave, width: 30.w, fit: BoxFit.cover),
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
                      Positioned(
                        bottom: -20.h,
                        left: 0,
                        right: 0,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: WaterActionButton(
                            iconWidget: SvgPicture.asset(SvgIcons.waterGlass, width: 40.w, height: 40.h),
                            label: '1 L',
                            onTap: () => addWater(1.0),
                            size: 80,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Action buttons row
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 40.h),
                          child: WaterActionButton(
                            iconWidget: SvgPicture.asset(
                              SvgIcons.WarterAdd,
                              width: 30.w,
                              height: 30.w,
                              fit: BoxFit.contain,
                            ),
                            label: 'hydration.manual'.tr(),
                            onTap: _showManualAddSheet,
                            size: 80,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 40.h),
                          child: WaterActionButton(
                            iconWidget: SvgPicture.asset(
                              SvgIcons.WaterClock,
                              width: 30.w,
                              height: 30.w,
                              fit: BoxFit.contain,
                            ),
                            label: 'hydration.reminder_time_label'.tr(),
                            onTap: _showWaterReminderScreen,
                            size: 80,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Minus button
                  Padding(
                    padding: EdgeInsetsDirectional.only(bottom: 50.h, start: 30.w),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: GestureDetector(
                        onTap: () => removeWater(0.25),
                        child: Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
                          child: Icon(Icons.remove, color: AppColors.hydrationAccent, size: 24.sp),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
