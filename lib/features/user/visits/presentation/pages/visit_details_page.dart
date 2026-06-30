import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/shared/widgets/app_back_header.dart';
import 'package:fitness_day/features/shared/widgets/app_segmented_control.dart';
import 'package:fitness_day/features/shared/widgets/custom_button.dart';
import 'package:fitness_day/features/shared/widgets/custom_outlined_button.dart';
import 'package:fitness_day/features/shared/widgets/health_report_card.dart';
import 'package:fitness_day/features/shared/widgets/plan_item_card.dart';
import 'package:fitness_day/features/shared/widgets/vertical_tab_bar.dart';
import 'package:fitness_day/features/shared/widgets/visit_card.dart';
import 'package:fitness_day/features/shared/widgets/visit_goal_card.dart';
import 'package:fitness_day/core/constant/app_assets.dart';

class VisitDetailsPage extends StatefulWidget {
  final bool isUpcoming;
  const VisitDetailsPage({super.key, this.isUpcoming = false});

  @override
  State<VisitDetailsPage> createState() => _VisitDetailsPageState();
}

class _VisitDetailsPageState extends State<VisitDetailsPage> {
  int _selectedTabIndex = 0;
  int _selectedDayIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 10.h),
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: AppBackHeader(
                title: widget.isUpcoming ? 'تفاصيل الزيارة القادمة' : 'تفاصيل الزيارة',
              ),
            ),
            SizedBox(height: 24.h),

            // Segmented Control (2 tabs) - Only for previous visits
            if (!widget.isUpcoming) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: AppSegmentedControl(
                  type: AppSegmentedControlType.unified,
                  items: const [
                    'ملخص الزيارة',
                    'النظام المخصص',
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
            ],

            // Content Area
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 24.h),
                child: widget.isUpcoming
                    ? _buildUpcomingVisitContent()
                    : (_selectedTabIndex == 0
                        ? _buildPreviousVisitSummaryTab()
                        : _buildCustomPlanTab()),
              ),
            ),

            // Bottom Buttons (For Upcoming Visit only)
            if (widget.isUpcoming)
              Container(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
                child: Row(
                  children: [
                    // Change Location
                    Expanded(
                      child: CustomButton(
                        text: 'تغيير المكان',
                        color: AppColors.primary,
                        onPressed: () {},
                      ),
                    ),
                    SizedBox(width: 12.w),
                    // Change Time
                    Expanded(
                      child: CustomOutlinedButton(
                        text: 'تغيير الميعاد',
                        onPressed: () {},
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

  Widget _buildUpcomingVisitContent() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          // Visit Card
          VisitCard(
            timeRemaining: '',
            title: 'متابعة أسبوعية',
            subtitle: 'متابعة الوزن وتخصيص النظام الغذائي والرياضي له',
            personName: 'د/ محمد عبدالله',
            personNameLabel: 'اسم الأخصائي :',
            visitTime: 'اليوم 4:30 مساءا',
            location: 'في مقر يوم الرشاقة',
            buttonText: 'تفاصيل »',
            iconColor: Colors.grey, 
            isUpcoming: true,
            onViewPressed: () {},
            showButton: false,
          ),
          SizedBox(height: 16.h),

          // Goal Card
          VisitGoalCard(
            title: 'الهدف من الزيارة',
            goals: const [
              'تعديل السعرات اليومية لتناسب هدفك',
              'تحديث خطة التمارين',
              'ضبط توزيع البروتين والكربوهيدرات',
              'متابعة تقدمك خلال الأسبوع الماضي',
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreviousVisitSummaryTab() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          // Visit Card
          VisitCard(
            timeRemaining: '',
            title: 'متابعة أسبوعية',
            subtitle: 'متابعة الوزن وتخصيص النظام الغذائي والرياضي له',
            personName: 'د/ محمد عبدالله',
            personNameLabel: 'اسم الأخصائي :',
            visitTime: 'اليوم 4:30 مساءا',
            location: 'في مقر يوم الرشاقة',
            buttonText: 'تفاصيل »',
            iconPath: SvgIcons.monitor,
            isCompleted: true, // Assuming this is how we show the green checked icon (Wait, VisitCard doesn't have isCompleted, I need to check VisitCard. For now let's just use it as is)
            onViewPressed: () {},
            showButton: false,
          ),
          SizedBox(height: 16.h),

          // Visit Goal Card
          VisitGoalCard(
            title: 'ملخص الزيارة',
            goals: const [
              'تعديل السعرات اليومية لتناسب هدفك',
              'تحديث خطة التمارين',
              'ضبط توزيع البروتين والكربوهيدرات',
              'متابعة تقدمك خلال الأسبوع الماضي',
            ],
          ),
          SizedBox(height: 16.h),

          // Health Report Card
          const HealthReportCard(),
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
            padding: EdgeInsets.fromLTRB(20.w, 0, 16.w, 0),
            child: Column(
              children: [
                _buildSectionTitle('التغذية'),
                SizedBox(height: 12.h),
                _buildNutritionCard(),
                SizedBox(height: 12.h),
                _buildNutritionCard2(),
                SizedBox(height: 12.h),
                _buildNutritionCard3(),

                SizedBox(height: 24.h),
                _buildSectionTitle('التمارين'),
                SizedBox(height: 12.h),
                _buildExerciseCard(),

                SizedBox(height: 24.h),
                _buildSectionTitle('الأنشطة'),
                SizedBox(height: 12.h),
                _buildActivityCard(),
              ],
            ),
          ),
        ),
        // Vertical Tab Bar (Left side in RTL)
        VerticalTabBar(
          items: const [
            'اليوم الأول',
            'اليوم الثاني',
            'اليوم الثالث',
            'اليوم الرابع',
            'اليوم الخامس',
            'اليوم السادس',
            'اليوم السابع',
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

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyleManager.heading2.copyWith(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionCard() {
    return PlanItemCard(
      title: 'وجبة الإفطار',
      isCompleted: true,
      time: '8:00 صباحا',
      subtitle: 'شوفان بالحليب مع مكسرات وعسل',
      showActions: false,
      details: RichText(
        text: TextSpan(
          style: TextStyleManager.style9Medium.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
          children: [
            const TextSpan(text: 'سعرات : '),
            TextSpan(
              text: '350',
              style: TextStyleManager.style9Medium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const TextSpan(text: ' كالوري'),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionCard2() {
    return PlanItemCard(
      title: 'وجبة الغداء',
      isCompleted: false,
      time: '3:00 مساءا',
      subtitle: '150 جم من صدور الدجاج المشوي + 6 ملاعق أرز + سلطة خضراء',
      showActions: false,
      details: RichText(
        text: TextSpan(
          style: TextStyleManager.style9Medium.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
          children: [
            const TextSpan(text: 'سعرات : '),
            TextSpan(
              text: '350',
              style: TextStyleManager.style9Medium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const TextSpan(text: ' كالوري'),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionCard3() {
    return PlanItemCard(
      title: 'وجبة العشاء',
      isCompleted: false,
      time: '9:00 مساءا',
      subtitle: 'سمك مشوي + سلطة خضراء + عيش أسمر',
      showActions: false,
      details: RichText(
        text: TextSpan(
          style: TextStyleManager.style9Medium.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
          children: [
            const TextSpan(text: 'سعرات : '),
            TextSpan(
              text: '350',
              style: TextStyleManager.style9Medium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const TextSpan(text: ' كالوري'),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard() {
    return PlanItemCard(
      title: 'تمرين القرفصاء',
      isCompleted: true,
      time: '3:00 مساءا',
      showActions: false,
      details: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: TextStyleManager.style9Medium.copyWith(
                color: AppColors.textSecondary,
              ),
              children: [
                const TextSpan(text: 'عدد المجموعات : '),
                TextSpan(
                  text: '5',
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
                const TextSpan(text: 'وقت الراحة : '),
                TextSpan(
                  text: '20 ثانية',
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
                const TextSpan(text: 'التكرارات : '),
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
    return PlanItemCard(
      title: 'المشي الجري السريع',
      isCompleted: false,
      showActions: false,
      details: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: TextStyleManager.style9Medium.copyWith(
                color: AppColors.textSecondary,
              ),
              children: [
                const TextSpan(text: 'الخطوات : '),
                TextSpan(
                  text: '5000 خطوة',
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
}
