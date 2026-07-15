import 'dart:ui' as ui;
import 'package:fitness_day/core/widgets/plan_item_card.dart';
import 'package:fitness_day/core/widgets/vertical_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/widgets/app_back_header.dart';
import 'package:fitness_day/core/widgets/app_segmented_control.dart';
import 'package:fitness_day/core/widgets/upcoming_visit_show_screen.dart';
import 'package:fitness_day/core/widgets/visit_card.dart';
import 'package:fitness_day/core/widgets/visit_goal_card.dart';
import 'package:fitness_day/core/widgets/custom_button.dart';
import 'package:fitness_day/core/widgets/custom_outlined_button.dart';
import 'package:fitness_day/core/widgets/message_icon_button.dart';
import 'package:fitness_day/core/widgets/reschedule_visit_dialog.dart';
import '../../../../../core/theme/app_text_styles.dart';
import 'package:fitness_day/features/specialist/visits/presentation/widgets/report_text_field.dart';
import '../../../../shared/conversations/presentation/pages/chat_details_page.dart';
import 'add_activity_page.dart';
import 'add_exercise_page.dart';
import 'add_meal_page.dart';

class VisitDetailsPage extends StatefulWidget {
  final bool isUpcoming;
  final String assessmentId;
  const VisitDetailsPage({super.key, this.isUpcoming = false, this.assessmentId = ''});

  @override
  State<VisitDetailsPage> createState() => _VisitDetailsPageState();
}

class _VisitDetailsPageState extends State<VisitDetailsPage> {
  int _selectedTabIndex = 0;
  int _selectedDayIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.isUpcoming) {
      return UpcomingVisitShowScreen(
        title: 'visit_details.title'.tr(),
        trailingWidget: MessageIconButton(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChatDetailsPage()),
            );
          },
        ),
        visitTimeRemaining: 'visits.in_minutes'.tr(args: ['25']),
        visitTitle: 'visits.dummy_title'.tr(),
        visitSubtitle: 'visits.dummy_subtitle'.tr(),
        personName: 'visits.dummy_client'.tr(),
        personNameLabel: 'visits.client_name_label'.tr(),
        visitTime: '${'visits.today'.tr()} 4:30 ${'visits.pm'.tr()}',
        visitLocation: 'visits.hq_location'.tr(),
        visitGoalTitle: 'visit_details.visit_goal_title'.tr(),
        visitGoals: [
          'visit_details.goal_1'.tr(),
          'visit_details.goal_2'.tr(),
          'visit_details.goal_3'.tr(),
          'visit_details.goal_4'.tr(),
        ],
        bottomAction: Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'visit_details.start_visit'.tr(),
                onPressed: () {},
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: CustomOutlinedButton(
                text: 'visit_details.reschedule'.tr(),
                onPressed: () {
                  showRescheduleDialog(context, widget.assessmentId);
                },
              ),
            ),
          ],
        ),
      );
    }
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
                        MaterialPageRoute(builder: (context) => const ChatDetailsPage()),
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
              if (widget.isUpcoming || _selectedTabIndex != 0)
                Container(
                  padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
                  child: (widget.isUpcoming && _selectedTabIndex == 0)
                      ? Row(
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
                                  showRescheduleDialog(context, widget.assessmentId);
                                },
                              ),
                            ),
                          ],
                        )
                      : CustomButton(
                          text: 'visit_details.end_visit'.tr(),
                          color: AppColors.greenMint,
                          onPressed: () {},
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
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Visit Card
          VisitCard(
            timeRemaining: widget.isUpcoming
                ? 'visits.in_minutes'.tr(args: ['25'])
                : '',
            title: 'visits.dummy_title'.tr(),
            subtitle: 'visits.dummy_subtitle'.tr(),
            personName: 'visits.dummy_client'.tr(),
            visitTime: '${'visits.today'.tr()} 4:30 ${'visits.pm'.tr()}',
            location: 'visits.hq_location'.tr(),
            buttonText: 'visits.view_visit'.tr(),
            onViewPressed: () {},
            isUpcoming: widget.isUpcoming,
            showButton: false,
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
      ),
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
                      MaterialPageRoute(
                        builder: (_) => const AddExercisePage(),
                      ),
                    );
                  },
                ),
                SizedBox(height: 16.h),
                _buildActionCard(
                  title: 'visit_details.add_activity'.tr(),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddActivityPage(),
                      ),
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
        VerticalTabBar(
          items: [
            'visit_details.day_1'.tr(),
            'visit_details.day_2'.tr(),
            'visit_details.day_3'.tr(),
            'visit_details.day_4'.tr(),
            'visit_details.day_5'.tr(),
            'visit_details.day_6'.tr(),
            'visit_details.day_7'.tr(),
          ],
          selectedIndex: _selectedDayIndex,
          onItemSelected: (index) {
            setState(() {
              _selectedDayIndex = index;
            });
          },
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.4),
          width: 1,
        ),
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
          Text(title, style: TextStyleManager.style11Medium),
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'visit_details.add'
                      .tr()
                      .replaceAll('»', '')
                      .replaceAll('«', '')
                      .trim(),
                  style: TextStyleManager.smallButtons.copyWith(
                    color: AppColors.white,
                  ),
                ),
                SizedBox(width: 2.w),
                Icon(
                  Directionality.of(context) == ui.TextDirection.rtl
                      ? Icons.keyboard_double_arrow_left
                      : Icons.keyboard_double_arrow_right,
                  size: 16.sp,
                  color: AppColors.white,
                ),
              ],
            ),
          ),
        ],
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

  
  Widget _buildNutritionCard() {
    return PlanItemCard(showActions: true, 
      title: 'visit_details_mock_breakfast'.tr(),
      isCompleted: true,
      time: 'visit_details_mock_breakfast_time'.tr(),
      subtitle: 'visit_details_mock_breakfast_desc'.tr(),
      details: RichText(
        text: TextSpan(
          style: TextStyleManager.style9Medium.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
          children: [
            TextSpan(text: 'visit_details_mock_qty_oats'.tr()),
            TextSpan(
              text: '45g',
              style: TextStyleManager.style9Medium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(text: 'visit_details_mock_milk'.tr()),
            TextSpan(
              text: '250ml',
              style: TextStyleManager.style9Medium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(text: 'visit_details_mock_nuts'.tr()),
            TextSpan(
              text: '10g',
              style: TextStyleManager.style9Medium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(text: 'visit_details_mock_honey'.tr()),
            TextSpan(
              text: '5g',
              style: TextStyleManager.style9Medium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard() {
    return PlanItemCard(showActions: true, 
      title: 'visit_details_mock_plank'.tr(),
      isCompleted: true,
      time: 'visit_details_mock_breakfast_time'.tr(),
      details: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: TextStyleManager.style9Medium.copyWith(
                color: AppColors.textSecondary,
              ),
              children: [
                TextSpan(text: 'visit_details_mock_sets'.tr()),
                TextSpan(
                  text: 'visit_details_mock_5_sets'.tr(),
                  style: TextStyleManager.style9Medium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          RichText(
            text: TextSpan(
              style: TextStyleManager.style9Medium.copyWith(
                color: AppColors.textSecondary,
              ),
              children: [
                TextSpan(text: 'visit_details_mock_rest_time'.tr()),
                TextSpan(
                  text: 'visit_details_mock_20_sec'.tr(),
                  style: TextStyleManager.heading3.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          RichText(
            text: TextSpan(
              style: TextStyleManager.style9Medium.copyWith(
                color: AppColors.textSecondary,
              ),
              children: [
                TextSpan(text: 'visit_details_mock_reps'.tr()),
                TextSpan(
                  text: '5',
                  style: TextStyleManager.style9Medium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard() {
    return PlanItemCard(showActions: true, 
      title: 'visit_details_mock_walk'.tr(),
      isCompleted: false,
      details: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: TextStyleManager.style9Medium.copyWith(
                color: AppColors.textSecondary,
              ),
              children: [
                TextSpan(text: 'visit_details_mock_steps'.tr()),
                TextSpan(
                  text: 'visit_details_mock_5000_steps'.tr(),
                  style: TextStyleManager.style9Medium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          RichText(
            text: TextSpan(
              style: TextStyleManager.style9Medium.copyWith(
                color: AppColors.textSecondary,
              ),
              children: [
                TextSpan(text: 'visit_details_mock_rest'.tr()),
                TextSpan(
                  text: 'visit_details_mock_20_sec'.tr(),
                  style: TextStyleManager.style9Medium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
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
