import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/specialist/clients/presentation/widgets/client_profile/components/info_card.dart';

class ClientDataTab extends StatelessWidget {
  const ClientDataTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          _buildProfileHeader(),
          SizedBox(height: 16.h),
          InfoCard(
            title: 'clients_page.bmi_report'.tr(),
            icon: Icon(Icons.monitor_weight_outlined, color: AppColors.primary, size: 24.sp),
            data: {
              'clients_page.body_mass'.tr(): '19.44 ${'clients_page.bmi_unit'.tr()}',
              'clients_page.ideal_weight'.tr(): '68.00 ${'clients_page.kg'.tr()}',
              'clients_page.calories'.tr(): '1025 ${'clients_page.calorie'.tr()}',
              'clients_page.protein_needs'.tr(): '45 ${'clients_page.gram'.tr()}',
            },
            greenValues: [
              'clients_page.body_mass'.tr(),
              'clients_page.ideal_weight'.tr(),
              'clients_page.calories'.tr(),
              'clients_page.protein_needs'.tr(),
            ],
          ),
          InfoCard(
            title: 'clients_page.diet_plan'.tr(),
            icon: Icon(Icons.assignment_outlined, color: AppColors.primary, size: 24.sp),
            data: {
              'clients_page.diet_type'.tr(): 'نظام غذائي متنوع', // "Mixed Diet"
              'clients_page.body_mass'.tr(): '2', // Wait, design says 'كتلة الجسم : 2', we will just put '2'
              'clients_page.favorite_foods'.tr(): 'وجبات صحية قليلة الملح', // "Low salt healthy meals"
              'clients_page.food_allergies'.tr(): 'وجبات التي تحتوي على الفول', // "Meals containing beans"
            },
            greenValues: [
              'clients_page.diet_type'.tr(),
              'clients_page.body_mass'.tr(),
              'clients_page.favorite_foods'.tr(),
              'clients_page.food_allergies'.tr(),
            ],
          ),
          // InfoCard(
          //   title: 'clients_page.physical_activity'.tr(),
          //   icon: Icon(Icons.fitness_center_outlined, color: AppColors.primary, size: 24.sp),
          //   data: {
          //     'clients_page.daily_steps'.tr(): '5000',
          //   },
          //   greenValues: [
          //     'clients_page.daily_steps'.tr(),
          //   ],
          // ),
          // SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Badge
          Align(
            alignment: AlignmentDirectional.topEnd,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7BDB88), Color(0xFF52C863)],
                  begin: AlignmentDirectional.centerStart,
                  end: AlignmentDirectional.centerEnd,
                ),
                borderRadius: BorderRadiusDirectional.only(
                  topEnd: Radius.circular(16.r),
                  bottomStart: Radius.circular(16.r),
                ),
              ),
              child: Text(
                'clients_page.commitment_rate'.tr(args: ['85']),
                style: TextStyleManager.style10Medium.copyWith(
                  color: AppColors.greenForest,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 70.r,
                      height: 70.r,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.divider, width: 2),
                      ),
                      child: ClipOval(
                        child: Icon(Icons.person, size: 40.sp, color: Colors.grey),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Text(
                        'محمد عبدالله',
                        style: TextStyleManager.style14Bold.copyWith(
                          color: AppColors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeaderDetail('clients_page.goal'.tr(), 'clients_page.dummy_goal'.tr()),
                          SizedBox(height: 8.h),
                          _buildHeaderDetail('clients_page.height_short'.tr(), '167 ${'clients_page.cm'.tr()}'),
                          SizedBox(height: 8.h),
                          _buildHeaderDetail('النشاط', 'خامل'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeaderDetail('clients_page.age'.tr(), '28'),
                          SizedBox(height: 8.h),
                          _buildHeaderDetail('clients_page.weight'.tr(), '58 ${'clients_page.kg'.tr()}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderDetail(String label, String value) {
    return Text.rich(
      TextSpan(
        text: '$label : ',
        style: TextStyleManager.style11Medium.copyWith(
          color: AppColors.textPrimary,
        ),
        children: [
          TextSpan(
            text: value,
            style: TextStyleManager.style11Medium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
