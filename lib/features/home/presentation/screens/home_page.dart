import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/appointment_card.dart';
import '../widgets/home_header.dart';
import '../widgets/performance_summary_section.dart';
import '../widgets/section_header.dart';
import '../widgets/task_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundTint,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Area
              Container(
                decoration: BoxDecoration(
                  color: AppColors.backgroundTint,
                ),
                child: const HomeHeader(),
              ),
              
              SizedBox(height: 16.h),
              
              // Main Content Area with White Background (optional based on exact design)
              // But looking at the design, the background is tinted until below the performance summary
              // Actually, the background is white below the summary. Let's make a container for the rest.
              
              Stack(
                children: [
                  // White background for the rest of the content
                  Container(
                    margin: EdgeInsets.only(top: 60.h), // Offset to put the summary card overlapping
                    decoration: BoxDecoration(
                      color: AppColors.white,
                    ),
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height,
                    ),
                  ),
                  
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      children: [
                        const PerformanceSummarySection(),
                        
                        SizedBox(height: 32.h),
                        
                        SectionHeader(
                          title: "home.upcoming_appointments".tr(),
                        ),
                        SizedBox(height: 16.h),
                        const AppointmentCard(),
                        
                        SizedBox(height: 32.h),
                        
                        SectionHeader(
                          title: "home.todays_tasks".tr(),
                          onMorePressed: () {
                            // TODO: Handle see more
                          },
                        ),
                        SizedBox(height: 16.h),
                        const TaskCard(),
                        SizedBox(height: 16.h),
                        const TaskCard(), // Showing a second one as per design snippet
                        
                        SizedBox(height: 32.h),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
