import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_back_header.dart';
import 'package:fitness_day/core/widgets/info_table_card.dart';
import 'package:fitness_day/core/widgets/visit_goal_card.dart';

class MealDetailsPage extends StatelessWidget {
  const MealDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.splashBackgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 10.h),
                // Header
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: const AppBackHeader(
                    title: 'تفاصيل الوجبة',
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'مضافة بواسطة يوم الرشاقة',
                  style: TextStyleManager.style11Medium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 24.h),

                // Circular Image
                Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: const DecorationImage(
                      image: NetworkImage('https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400'),
                      fit: BoxFit.cover,
                    ),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 4.w,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                // Meal Name
                Text(
                  'صدر دجاج مشوية وخضار سوتيه',
                  style: TextStyleManager.heading2.copyWith(
                    color: AppColors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),

                // Description
                Text(
                  'صدور دجاج مشوية: 200 جرام\nخضار سوتيه 200 جرام',
                  textAlign: TextAlign.center,
                  style: TextStyleManager.style11Medium.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 16.h),

                // Calories Pill
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    gradient: AppColors.timeRemainingGradient,
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'كالوري',
                        style: TextStyleManager.style11Medium.copyWith(
                          color: AppColors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '450',
                        style: TextStyleManager.style16Bold.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text('🔥', style: TextStyleManager.style16Bold),
                    ],
                  ),
                ),
                SizedBox(height: 32.h),

                // Preparation Method
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: const VisitGoalCard(
                    title: 'طريقة التحضير :',
                    goals: [
                      'تُتبل صدور الدجاج بالملح والفلفل والليمون والثوم، ثم تُشوى على جريل أو طاسة ساخنة حتى تنضج. وفي نفس الوقت تُشوح الخضار (بروكلي، جزر، كوسة) بقليل من زيت الزيتون مع ملح وفلفل لمدة دقائق حتى تطرى قليلًا، ثم تُقدم مع الدجاج ساخن.'
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                // Food Data Table
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: const InfoTableCard(
                    title: 'بيانات الطعام',
                    data: [
                      TableRowData(label: 'السعرات بالكالوري', value: '450'),
                      TableRowData(label: 'الدهون بالجرام', value: '14'),
                      TableRowData(label: 'الكربوهيدرات بالجرام', value: '12'),
                      TableRowData(label: 'سكر بالجرام', value: '6'),
                      TableRowData(label: 'البروتين بالجرام', value: '66'),
                      TableRowData(label: 'كوليسترول بالجرام', value: '5'),
                      TableRowData(label: 'فيتامين د بالجرام', value: '5'),
                      TableRowData(label: 'الالياف بالجرام', value: '4'),
                      TableRowData(label: 'البروتين :', value: '17.8'),
                    ],
                  ),
                ),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
