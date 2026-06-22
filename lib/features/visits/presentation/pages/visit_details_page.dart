import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/features/visits/presentation/widgets/reschedule_visit_dialog.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/widgets/app_back_header.dart';
import 'package:fitness_day/core/widgets/app_segmented_control.dart';
import 'package:fitness_day/core/widgets/visit_card.dart';
import 'package:fitness_day/core/widgets/visit_goal_card.dart';
import 'package:fitness_day/core/widgets/custom_button.dart';
import 'package:fitness_day/core/widgets/custom_outlined_button.dart';
import 'package:fitness_day/core/widgets/message_icon_button.dart';
import 'package:fitness_day/features/visits/presentation/widgets/report_text_field.dart';
import 'package:fitness_day/features/visits/presentation/pages/add_meal_page.dart';
import 'package:fitness_day/features/visits/presentation/pages/add_exercise_page.dart';
import 'package:fitness_day/features/visits/presentation/pages/add_activity_page.dart';
import 'package:fitness_day/features/conversations/presentation/pages/conversations_page.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_text_styles.dart';

class VisitDetailsPage extends StatefulWidget {
  const VisitDetailsPage({super.key});

  @override
  State<VisitDetailsPage> createState() => _VisitDetailsPageState();
}

class _VisitDetailsPageState extends State<VisitDetailsPage> {
  int _selectedTabIndex = 0;
  int _selectedDayIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.visitsBackgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 20.h),

              // 1. Back Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: AppBackHeader(
                  title: 'visit_details.title'.tr(),
                  trailingWidget: MessageIconButton(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ConversationsPage()),
                      );
                    },
                  ),
                ),
              ),

              SizedBox(height: 32.h),

              // 2. Segmented Control (3 tabs) — reversed so first tab is on the right (RTL)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: AppSegmentedControl(
                  type: AppSegmentedControlType.unified,
                  items: [
                    'visit_details.tab_visit_data'.tr(),
                    'visit_details.tab_report'.tr(),
                    'visit_details.tab_custom_plan'.tr(),
                  ],
                  selectedIndex: _selectedTabIndex,
                  onItemSelected: (index) {
                    setState(() {
                      _selectedTabIndex = index;
                    });
                  },
                ),
              ),

              SizedBox(height: 24.h),

              // 3. Content Area
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 24.h),
                  child: _buildTabContent(),
                ),
              ),

              // 4. Bottom Buttons
              Container(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
                child: (_selectedTabIndex == 1 || _selectedTabIndex == 2)
                    ? CustomButton(
                        text: 'visit_details.end_visit'.tr(),
                        color: AppColors.greenMint, // Match lighter green from design
                        onPressed: () {},
                      )
                    : Row(
                        children: [
                          // Start Visit (Primary) — on the right in RTL
                          Expanded(
                            child: CustomButton(
                              text: 'visit_details.start_visit'.tr(),
                              onPressed: () {},
                            ),
                          ),
                          SizedBox(width: 12.w),
                          // Reschedule (Outlined) — on the left in RTL
                          Expanded(
                            child: CustomOutlinedButton(
                              text: 'visit_details.reschedule'.tr(),
                              onPressed: () {
                                showRescheduleDialog(context);
                              },
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildVisitDataTab();
      case 1:
        return _buildReportTab();
      case 2:
        return _buildCustomPlanTab();
      default:
        return _buildVisitDataTab();
    }
  }

  Widget _buildVisitDataTab() {
    return Column(
      children: [
        // Visit Card
        VisitCard(
          timeRemaining: 'visits.in_minutes'.tr(args: ['25']),
          title: 'visits.dummy_title'.tr(),
          subtitle: 'visits.dummy_subtitle'.tr(),
          clientName: 'visits.dummy_client'.tr(),
          visitTime: '${'visits.today'.tr()} 4:30 ${'visits.pm'.tr()}',
          location: 'visits.hq_location'.tr(),
          buttonText: 'visits.view_visit'.tr(),
          onViewPressed: () {},
        ),

        SizedBox(height: 16.h),

        // Visit Goal Card
        VisitGoalCard(
          title: 'visit_details.visit_goal_title'.tr(),
          goals: [
            'visit_details.goal_1'.tr(),
            'visit_details.goal_2'.tr(),
            'visit_details.goal_3'.tr(),
            'visit_details.goal_4'.tr(),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomPlanTab() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Content Area (Right side in RTL)
        Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 16.w, 0),
            child: Column(
              children: [
                _buildActionCard(
                  title: 'visit_details.add_meal'.tr(),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddMealPage()),
                    );
                  },
                ),
                SizedBox(height: 16.h),
                _buildActionCard(
                  title: 'visit_details.add_exercise'.tr(),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddExercisePage()),
                    );
                  },
                ),
                SizedBox(height: 16.h),
                _buildActionCard(
                  title: 'visit_details.add_activity'.tr(),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddActivityPage()),
                    );
                  },
                ),
                SizedBox(height: 32.h),

                // Added Items List
                _buildSectionTitle('visit_details.nutrition'.tr(), 1),
                SizedBox(height: 12.h),
                _buildNutritionCard(),
                
                SizedBox(height: 24.h),
                _buildSectionTitle('visit_details.exercises'.tr(), 1),
                SizedBox(height: 12.h),
                _buildExerciseCard(),

                SizedBox(height: 24.h),
                _buildSectionTitle('visit_details.activity'.tr(), 1),
                SizedBox(height: 12.h),
                _buildActivityCard(),
              ],
            ),
          ),
        ),
        // Vertical Tab Bar (Left side in RTL)
        _buildVerticalTabBar(),
      ],
    );
  }

  Widget _buildActionCard({required String title, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyleManager.style11Medium,
          ),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
              minimumSize: const Size(0, 0),
              elevation: 0,
            ),
            child: Text(
              'visit_details.add'.tr(),
              style: TextStyleManager.smallButtons.copyWith(
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalTabBar() {
    final days = [
      'visit_details.day_1'.tr(),
      'visit_details.day_2'.tr(),
      'visit_details.day_3'.tr(),
      'visit_details.day_4'.tr(),
      'visit_details.day_5'.tr(),
      'visit_details.day_6'.tr(),
      'visit_details.day_7'.tr(),
    ];

    return Container(
      width: 60.w,
      decoration: BoxDecoration(
        color: AppColors.backgroundTint,
        borderRadius: BorderRadius.horizontal(
          right: Radius.circular(20.r),
        ),
      ),
      child: Column(
        children: List.generate(days.length, (index) {
          final isSelected = _selectedDayIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDayIndex = index;
              });
            },
            child: Container(
              height: 70.h,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: isSelected
                    ? BorderRadius.horizontal(right: Radius.circular(20.r))
                    : null,
                border: !isSelected && index < days.length - 1
                    ? const Border(
                        bottom: BorderSide(color: AppColors.white, width: 1),
                      )
                    : null,
              ),
              child: Center(
                child: Text(
                  days[index].replaceAll(' ', '\n'), // Put day name and number on separate lines
                  textAlign: TextAlign.center,
                  style: TextStyleManager.style10Medium.copyWith(
                    color: isSelected ? AppColors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSectionTitle(String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyleManager.heading2.copyWith(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Text(
          count.toString(),
          style: TextStyleManager.heading3.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBaseCard({
    required String title,
    required bool isCompleted,
    String? time,
    String? subtitle,
    required Widget details,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: AppShadows.primaryShadow,
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5), width: 1),
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyleManager.heading3,
                ),
              ),
              if (time != null) ...[
                SvgPicture.asset(SvgIcons.clock, height: 13.sp),
                SizedBox(width: 4.w),
                Text(
                  time,
                  style: TextStyleManager.style9Medium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
              const SizedBox(width: 7,),
              Icon(
                Icons.check_circle_rounded,
                color: isCompleted ? AppColors.primary : AppColors.divider,
                size: 22.sp,
              ),
            ],
          ),
          
          if (subtitle != null) ...[
            SizedBox(height: 8.h),
            Text(
              subtitle,
              style: TextStyleManager.style11Medium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],

          SizedBox(height: 12.h),
          details,
          SizedBox(height: 16.h),

          // Bottom Buttons
          Row(
            children: [
              // Edit Button (Green) - Right side in RTL
              SizedBox(width: 0.w),
              Spacer(),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    elevation: 0,
                  ),
                  child: Text(
                    'visit_details.edit'.tr(),
                    style: TextStyleManager.smallButtons.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              // Delete Button (Red) - Left side in RTL
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.red,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    elevation: 0,
                  ),
                  child: Text(
                    'visit_details.delete'.tr(),
                    style: TextStyleManager.smallButtons.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionCard() {
    return _buildBaseCard(
      title: 'وجبة الافطار',
      isCompleted: true,
      time: '8:00 صباحا',
      subtitle: 'شوفان بالحليب مع مكسرات وعسل',
      details: RichText(
        text: TextSpan(
          style: TextStyleManager.style9Medium.copyWith(color: AppColors.textSecondary, height: 1.5),
          children: [
            const TextSpan(text: 'الكمية: شوفان : '),
            TextSpan(text: '45g', style: TextStyleManager.style9Medium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
            const TextSpan(text: ' - حليب : '),
            TextSpan(text: '250ml', style: TextStyleManager.style9Medium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
            const TextSpan(text: ' -مكسرات : '),
            TextSpan(text: '10g', style: TextStyleManager.style9Medium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
            const TextSpan(text: ' - عسل : '),
            TextSpan(text: '5g', style: TextStyleManager.style9Medium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard() {
    return _buildBaseCard(
      title: 'تمرين البلانك',
      isCompleted: true,
      time: '8:00 صباحا',
      details: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: TextStyleManager.style9Medium.copyWith(color: AppColors.textSecondary,),
              children: [
                const TextSpan(text: 'عدد المجموعات : '),
                TextSpan(text: '5 مجموعات', style: TextStyleManager.style9Medium.copyWith(color: AppColors.primary)),
              ],
            ),
          ),
          RichText(
            text: TextSpan(
              style: TextStyleManager.style9Medium.copyWith(color: AppColors.textSecondary,),
              children: [
                const TextSpan(text: 'مدة الاستراحة بين المجموعات : '),
                TextSpan(text: '20 ثانيه', style: TextStyleManager.heading3.copyWith(color: AppColors.primary)),
              ],
            ),
          ),
          RichText(
            text: TextSpan(
              style: TextStyleManager.style9Medium.copyWith(color: AppColors.textSecondary,),
              children: [
                const TextSpan(text: 'عدد التكرارات : '),
                TextSpan(text: '5', style: TextStyleManager.style9Medium.copyWith(color: AppColors.primary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard() {
    return _buildBaseCard(
      title: 'تمرين المشي',
      isCompleted: false,
      details: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: TextStyleManager.style9Medium.copyWith(color: AppColors.textSecondary),
              children: [
                const TextSpan(text: 'عدد الخطوات : '),
                TextSpan(text: '5000 خطوة', style: TextStyleManager.style9Medium.copyWith(color: AppColors.primary,)),
              ],
            ),
          ),
          RichText(
            text: TextSpan(
              style: TextStyleManager.style9Medium.copyWith(color: AppColors.textSecondary),
              children: [
                const TextSpan(text: 'مدة الاستراحة : '),
                TextSpan(text: '20 ثانيه', style: TextStyleManager.style9Medium.copyWith(color: AppColors.primary,)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportTab() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          ReportTextField(
            label: '${'visit_details.weight'.tr()} :',
            hintText: 'visit_details.write_weight'.tr(),
            suffixText: 'visit_details.kg'.tr(),
          ),
          SizedBox(height: 16.h),
          ReportTextField(
            label: '${'visit_details.height'.tr()} :',
            hintText: 'visit_details.write_height'.tr(),
            suffixText: 'visit_details.cm'.tr(),
          ),
          SizedBox(height: 16.h),
          ReportTextField(
            label: 'visit_details.bmi'.tr(),
            hintText: 'visit_details.bmi'.tr(),
          ),
          SizedBox(height: 16.h),
          ReportTextField(
            label: 'visit_details.body_fat_percentage'.tr(),
            hintText: 'visit_details.write_body_fat_percentage'.tr(),
          ),
          SizedBox(height: 16.h),
          ReportTextField(
            label: 'visit_details.fat_mass'.tr(),
            hintText: 'visit_details.fat_mass'.tr(),
            suffixText: 'visit_details.kg'.tr(),
          ),
          SizedBox(height: 16.h),
          ReportTextField(
            label: 'visit_details.muscle_weight'.tr(),
            hintText: 'visit_details.muscle_weight'.tr(),
            suffixText: 'visit_details.kg'.tr(),
          ),
          SizedBox(height: 16.h),
          ReportTextField(
            label: '${'visit_details.metabolic_rate'.tr()} :',
            hintText: 'visit_details.write_total_metabolic_rate'.tr(),
          ),
          SizedBox(height: 16.h),
          ReportTextField(
            label: 'visit_details.lean_mass'.tr(),
            hintText: 'visit_details.write_lean_mass'.tr(),
          ),
          SizedBox(height: 16.h),
          ReportTextField(
            label: '${'visit_details.muscle_percentage'.tr()} :',
            hintText: 'visit_details.write_muscle_percentage'.tr(),
          ),
          SizedBox(height: 16.h),
          ReportTextField(
            label: 'visit_details.protein_percentage'.tr(),
            hintText: 'visit_details.write_protein_percentage'.tr(),
          ),
        ],
      ),
    );
  }
}
