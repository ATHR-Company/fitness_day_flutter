import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/widgets/app_back_header.dart';
import 'package:fitness_day/core/widgets/visit_card.dart';
import 'package:fitness_day/core/widgets/visit_goal_card.dart';

class UpcomingVisitShowScreen extends StatelessWidget {
  final String title;
  final Widget? trailingWidget;
  final String visitTimeRemaining;
  final String visitTitle;
  final String visitSubtitle;
  final String personName;
  final String personNameLabel;
  final String visitTime;
  final String visitLocation;
  final String visitGoalTitle;
  final List<String> visitGoals;
  final Widget bottomAction;

  const UpcomingVisitShowScreen({
    super.key,
    required this.title,
    this.trailingWidget,
    required this.visitTimeRemaining,
    required this.visitTitle,
    required this.visitSubtitle,
    required this.personName,
    required this.personNameLabel,
    required this.visitTime,
    required this.visitLocation,
    required this.visitGoalTitle,
    required this.visitGoals,
    required this.bottomAction,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
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
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: AppBackHeader(
                  title: title,
                  trailingWidget: trailingWidget,
                ),
              ),
              SizedBox(height: 24.h),

              // Content Area
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 24.h),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      children: [
                        // Visit Card
                        VisitCard(
                          timeRemaining: visitTimeRemaining,
                          title: visitTitle,
                          subtitle: visitSubtitle,
                          personName: personName,
                          personNameLabel: personNameLabel,
                          visitTime: visitTime,
                          location: visitLocation,
                          buttonText: 'تفاصيل »',
                          isUpcoming: true,
                          onViewPressed: () {},
                          showButton: false,
                        ),
                        SizedBox(height: 16.h),

                        // Goal Card
                        VisitGoalCard(
                          title: visitGoalTitle,
                          goals: visitGoals,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Action
              Container(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
                child: bottomAction,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
