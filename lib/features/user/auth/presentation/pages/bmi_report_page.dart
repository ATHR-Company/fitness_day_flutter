import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/routes/user_routes/app_routes.dart';
import 'package:fitness_day/core/widgets/app_back_header.dart';
import 'package:fitness_day/core/widgets/custom_button.dart';
import 'package:fitness_day/features/user/auth/presentation/manager/user_setup_cubit.dart';

class BmiReportPage extends StatelessWidget {
  const BmiReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final report = context.read<UserSetupCubit>().bodyReport;

    // Fallbacks if report is null (e.g. if loaded directly/no survey completed)
    final bmiVal = report?.bmi.value.toString() ?? '';
    final bmiStatus = report?.bmi.status ?? '';
    final bmiUnit = report?.bmi.unit ?? '';
    
    final idealWeightVal = report?.idealWeight.value.toString() ?? '';
    final idealWeightUnit = report?.idealWeight.unit ?? '';

    final caloriesVal = report?.calories.value.toString() ?? '';
    final caloriesUnit = report?.calories.unit ?? '';

    final proteinVal = report?.proteinNeeds.value.toString() ?? '';
    final proteinUnit = report?.proteinNeeds.unit ?? '';

    final currentWeight = report?.currentData.weight.toString() ?? '';
    final currentWeightUnit = report?.currentData.weightUnit ?? '';

    final currentHeight = report?.currentData.height.toString() ?? '';
    final currentHeightUnit = report?.currentData.heightUnit ?? '';

    final activityLevelStr = report?.currentData.activityLevel ?? '';
    final goalStr = report?.currentData.goal ?? '';

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.splashBackgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: AppBackHeader(title: 'auth_bmi_report_title'.tr(), canBack: false,),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 16.h),
                      Text(
                        'auth_bmi_report_desc'.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyleManager.style14Medium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 32.h),

                      // 1. BMI Card
                      _buildMetricCard(
                        title: 'auth_bmi'.tr(),
                        value: '$bmiVal $bmiUnit',
                        iconPath: SvgIcons.height,
                        badge: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            bmiStatus,
                            style: TextStyleManager.style13Medium.copyWith(
                              color: AppColors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // 2. Ideal Weight Card
                      _buildMetricCard(
                        title: 'auth_ideal_weight'.tr(),
                        value: '$idealWeightVal $idealWeightUnit',
                        iconPath: SvgIcons.perfectWieght,
                      ),
                      SizedBox(height: 16.h),

                      // 3. Calories Card
                      _buildMetricCard(
                        title: 'auth_calories'.tr(),
                        value: '$caloriesVal $caloriesUnit',
                        iconPath: SvgIcons.activity,
                      ),
                      SizedBox(height: 16.h),

                      // 4. Protein Need Card
                      _buildMetricCard(
                        title: 'auth_protein_need'.tr(),
                        value: '$proteinVal $proteinUnit',
                        iconPath: SvgIcons.diet,
                      ),
                      SizedBox(height: 24.h),

                      // 5. Entered Data Container
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              left: -20.w,
                              top: 40.h,
                              child: SvgPicture.asset(
                                SvgIcons.halfApple,
                                width: 120.w,
                                height: 160.h,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'auth_entered_data'.tr(),
                                  style: TextStyleManager.heading2.copyWith(
                                    color: AppColors.black,
                                  ),
                                ),
                                SizedBox(height: 24.h),
                                _buildDataRow(
                                  'auth_weight'.tr(),
                                  '$currentWeight $currentWeightUnit',
                                  SvgIcons.weight,
                                ),
                                SizedBox(height: 16.h),
                                _buildDataRow(
                                  'auth_height'.tr(),
                                  '$currentHeight $currentHeightUnit',
                                  SvgIcons.height,
                                ),
                                SizedBox(height: 16.h),
                                _buildDataRow(
                                  'auth_activity_level'.tr(),
                                  activityLevelStr,
                                  SvgIcons.activity,
                                ),
                                SizedBox(height: 16.h),
                                _buildDataRow(
                                  'auth_goal'.tr(),
                                  goalStr,
                                  SvgIcons.goal,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 32.h),

                      // Button
                      CustomButton(
                        text: 'auth_start_now'.tr(),
                        onPressed: () {
                          context.go(UserAppRoutes.home);
                        },
                      ),
                      SizedBox(height: 32.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String iconPath,
    Widget? badge,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  height: 56.w,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.lightGreenBackground,
                    border: Border.all(color: AppColors.lightGreenBorder),
                  ),
                  child: SvgPicture.asset(
                    iconPath,
                    colorFilter: const ColorFilter.mode(
                      AppColors.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyleManager.style14Medium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      value,
                      style: TextStyleManager.style15Medium.copyWith(
                        color: AppColors.tealText,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
          ?badge,
        ],
      ),
    );
  }

  Widget _buildDataRow(String title, String value, String iconPath) {
    return Row(
      children: [
        Container(
          height: 48.w,
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.lightGreenBackground,
            border: Border.all(color: AppColors.lightGreenBorder),
          ),
          child: SvgPicture.asset(
            iconPath,
            colorFilter: const ColorFilter.mode(
              AppColors.primary,
              BlendMode.srcIn,
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyleManager.style14Medium.copyWith(
                color: AppColors.black,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4.h),
            Text(
              value,
              style: TextStyleManager.style14Medium.copyWith(
                color: AppColors.tealText,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
