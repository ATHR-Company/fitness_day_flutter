import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constant/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'stat_card.dart';

class PerformanceSummarySection extends StatelessWidget {
  const PerformanceSummarySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: AppShadows.primaryShadow,
      ),
      child: Stack(
        children: [
          // Background graphic/gradient wave
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.r),
              child: CustomPaint(
                painter: _WavePainter(),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "home.performance_summary_title".tr(),
                  style: TextStyleManager.heading2.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: StatCard(
                        title: "home.todays_visits".tr(),
                        value: "2",
                        iconPath: SvgIcons.todaysVisit,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: StatCard(
                        title: "home.needs_follow_up".tr(),
                        value: "5",
                        iconPath: SvgIcons.needMonitor,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: StatCard(
                        title: "home.clients_count".tr(),
                        value: "15",
                        iconPath: SvgIcons.clientsNumber,
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
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF56B76A), AppColors.primary], 
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, size.height * 0.5, size.width, size.height * 0.5))
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width, size.height);
    
    // Wave start at the right
    path.lineTo(size.width, size.height * 0.45);
    
    // Curve towards the left
    path.quadraticBezierTo(size.width * 0.6, size.height * 0.9, size.width * 0.3, size.height * 0.7);
    path.quadraticBezierTo(size.width * 0.1, size.height * 0.55, 0, size.height * 0.8);
    
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
