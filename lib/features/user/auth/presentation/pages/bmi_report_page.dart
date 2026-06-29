import 'package:fitness_day/core/theme/app_shadows.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/routes/user_routes/app_routes.dart';
import 'package:fitness_day/features/shared/widgets/app_back_header.dart';
import 'package:fitness_day/features/shared/widgets/custom_button.dart';

class BmiReportPage extends StatelessWidget {
  const BmiReportPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                child: const AppBackHeader(title: 'تقرير كتلة الجسم BMI'),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 16.h),
                      Text(
                        'اطلع على بياناتك الصحية وBMI الخاص بك لتبدأ رحلتك\nنحو صحة ورشاقة أفضل.',
                        textAlign: TextAlign.center,
                        style: TextStyleManager.style14Medium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 32.h),
                      
                      // 1. BMI Card
                      _buildMetricCard(
                        title: 'كتلة الجسم',
                        value: '19.44 كجم / متر',
                        iconPath: SvgIcons.height, // Using height.svg to match Figma (person with tape)
                        badge: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            'وزن طبيعي',
                            style: TextStyleManager.style13Medium.copyWith(color: AppColors.white),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      
                      // 2. Ideal Weight Card
                      _buildMetricCard(
                        title: 'الوزن المثالى',
                        value: '68.00 كيلوجرام',
                        iconPath: SvgIcons.perfectWieght,
                      ),
                      SizedBox(height: 16.h),
                      
                      // 3. Calories Card
                      _buildMetricCard(
                        title: 'السعرات الحرارية',
                        value: '1025 كالورى',
                        iconPath: SvgIcons.activity, // Will be solid green via colorFilter
                      ),
                      SizedBox(height: 16.h),
                      
                      // 4. Protein Need Card
                      _buildMetricCard(
                        title: 'احتياجك من البروتين',
                        value: '45 جرام',
                        iconPath: SvgIcons.diet,
                      ),
                      SizedBox(height: 24.h),
                      
                      // 5. Entered Data Container
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: Color(0xffFAFEFB),
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
                                  'البيانات المدخلة',
                                  style: TextStyleManager.heading2.copyWith(color: AppColors.black),
                                ),
                                SizedBox(height: 24.h),
                                _buildDataRow('الوزن', '68.00 كيلوجرام', SvgIcons.weight),
                                SizedBox(height: 16.h),
                                _buildDataRow('الطول', '167 سنتيمتر', SvgIcons.height),
                                SizedBox(height: 16.h),
                                _buildDataRow('مستوى النشاط', 'قليل النشاط', SvgIcons.activity),
                                SizedBox(height: 16.h),
                                _buildDataRow('الهدف من التطبيق', 'زيادة الوزن', SvgIcons.goal),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 32.h),
                      
                      // Button
                      CustomButton(
                        text: 'ابدأ الآن',
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
        boxShadow: AppShadows.primaryShadow,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56.w,
                height: 56.w,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE5F5E7),
                  border: Border.all(color: const Color(0xFFCCEBCF)),
                ),
                child: SvgPicture.asset(
                  iconPath,
                  colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyleManager.style14Medium.copyWith(color: AppColors.black),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    value,
                    style: TextStyleManager.style15Medium.copyWith(color: const Color(0xFF007E8E)),
                  ),
                ],
              ),
            ],
          ),
          if (badge != null) badge,
        ],
      ),
    );
  }

  Widget _buildDataRow(String title, String value, String iconPath) {
    return Row(
      children: [
        Container(
          width: 48.w,
          height: 48.w,
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFE5F5E7),
            border: Border.all(color: const Color(0xFFCCEBCF)),
          ),
          child: SvgPicture.asset(
            iconPath,
            colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
          ),
        ),
        SizedBox(width: 16.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyleManager.style14Medium.copyWith(color: AppColors.black),
            ),
            SizedBox(height: 4.h),
            Text(
              value,
              style: TextStyleManager.style14Medium.copyWith(color: const Color(0xFF007E8E)),
            ),
          ],
        ),
      ],
    );
  }
}
