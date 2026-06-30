import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/shared/widgets/visit_card.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/features/shared/widgets/app_header.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/user_app_drawer.dart';
import 'package:fitness_day/core/routes/user_routes/app_routes.dart';
import 'package:go_router/go_router.dart';

class VisitLogPage extends StatefulWidget {
  const VisitLogPage({super.key});

  @override
  State<VisitLogPage> createState() => _VisitLogPageState();
}

class _VisitLogPageState extends State<VisitLogPage> {
  int selectedDateIndex = 2; // For mock data

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.scaffoldBackground,
      endDrawer: const UserAppDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'سجل الزيارات', // This should be tr() eventually
              onMenuPressed: () {
                _scaffoldKey.currentState?.openEndDrawer();
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date Picker (Mock)
                    _buildDatePicker(),
                    SizedBox(height: 32.h),

                    // Upcoming Visit
                    Text(
                      'الزيارة القادمة',
                      style: TextStyleManager.heading3.copyWith(
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _buildUpcomingVisitCard(),

                    SizedBox(height: 32.h),

                    // Previous Visits
                    Text(
                      'الزيارات السابقة',
                      style: TextStyleManager.heading3.copyWith(
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _buildPreviousVisitCard(),
                    SizedBox(height: 16.h),
                    _buildPreviousVisitCard(), // duplicate for effect
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    final days = ['السبت', 'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة'];
    final dates = ['14', '15', '16', '17', '18', '19', '20'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(days.length, (index) {
        final isSelected = index == selectedDateIndex;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                selectedDateIndex = index;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                children: [
                Text(
                  days[index],
                  style: TextStyleManager.style11Medium.copyWith(
                    color: isSelected ? AppColors.white : AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  dates[index],
                  style: TextStyleManager.style14Bold.copyWith(
                    color: isSelected ? AppColors.white : AppColors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
        );
      }),
    );
  }

  Widget _buildUpcomingVisitCard() {
    return Stack(
      children: [
        VisitCard(
          timeRemaining: '',
          title: 'متابعة أسبوعية',
          subtitle: 'متابعة الوزن وتخصيص النظام الغذائي والرياضي له',
          personName: 'د/ محمد عبدالله',
          personNameLabel: 'اسم الأخصائي :',
          visitTime: 'اليوم 4:30 مساءا',
          location: 'في مقر يوم الرشاقة',
          buttonText: 'عرض الزيارة »',
          iconPath: SvgIcons.monitor,
          iconColor: Colors.grey,
          isUpcoming: true,
          onViewPressed: () {
            context.push(UserAppRoutes.upcomingVisitShow);
          },
        ),
      ],
    );
  }

  Widget _buildPreviousVisitCard() {
    return Stack(
      children: [
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
          isCompleted: true,
          onViewPressed: () {
            context.push(UserAppRoutes.visitDetails);
          },
        ),
      ],
    );
  }
}
