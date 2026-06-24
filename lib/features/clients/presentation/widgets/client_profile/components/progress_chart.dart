import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

class ProgressChart extends StatelessWidget {
  const ProgressChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'clients_page.visits_summary'.tr(),
              style: TextStyleManager.style14Bold,
            ),
            Row(
              children: [
                Text(
                  'clients_page.current_weight'.tr(),
                  style: TextStyleManager.style11Medium.copyWith(color: AppColors.textSecondary),
                ),
                Text(
                  ' 60 ${'clients_page.kg'.tr()}',
                  style: TextStyleManager.style11Medium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'clients_page.visit_number'.tr(args: ['6']),
                  style: TextStyleManager.style11Medium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '1/6/2026 4:30 مساءا',
                  style: TextStyleManager.style9Medium.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.keyboard_double_arrow_right, color: AppColors.divider, size: 20.sp),
                SizedBox(width: 8.w),
                Icon(Icons.keyboard_double_arrow_left, color: AppColors.primary, size: 20.sp),
              ],
            ),
          ],
        ),
        SizedBox(height: 16.h),
        SizedBox(
          height: 150.h,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 80,
              minY: 0,
              barTouchData: BarTouchData(
                enabled: false,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (group) => Colors.transparent,
                  tooltipPadding: EdgeInsets.zero,
                  tooltipMargin: 4,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${rod.toY.toInt()} ${'clients_page.kg'.tr()}',
                      TextStyleManager.style8Medium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      final isActive = value.toInt() == 6;
                      return Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: Text(
                          'ز ${value.toInt()}',
                          style: TextStyleManager.style9Medium.copyWith(
                            color: isActive ? AppColors.primary : AppColors.textPrimary,
                            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: [
                _buildBar(1, 58, false),
                _buildBar(2, 60, false),
                _buildBar(3, 58, false),
                _buildBar(4, 62, false),
                _buildBar(5, 60, false),
                _buildBar(6, 60, true), // Active visit
                _buildBar(7, 0, false),
                _buildBar(8, 0, false),
                _buildBar(9, 0, false),
              ],
            ),
          ),
        ),
      ],
    );
  }

  BarChartGroupData _buildBar(int x, double y, bool isActive) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: isActive ? AppColors.greenMint : AppColors.greenMint.withValues(alpha: 0.6),
          width: 32.w,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(2.r),
            topRight: Radius.circular(2.r),
          ),
        ),
      ],
      showingTooltipIndicators: y > 0 ? [0] : [],
    );
  }
}
