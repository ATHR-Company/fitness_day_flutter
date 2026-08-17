import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_shadows.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

class TableRowData {
  final String label;
  final String value;
  final String? unit;

  const TableRowData({
    required this.label,
    required this.value,
    this.unit,
  });
}

class InfoTableCard extends StatelessWidget {
  final String title;
  final List<TableRowData> data;

  const InfoTableCard({
    super.key,
    required this.title,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: AppShadows.primaryShadow,
      ),
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withValues(alpha: 0.8),
                  AppColors.primary.withValues(alpha: 0.5),
                ],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            ),
            child: Center(
              child: Text(
                title,
                style: TextStyleManager.heading2.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          // Data Rows
          ...data.asMap().entries.map((entry) {
            int index = entry.key;
            TableRowData rowData = entry.value;
            bool isEven = index % 2 != 0; // 0 is odd in UI, 1 is even visually in HealthReportCard
            bool isLast = index == data.length - 1;
            return _buildRow(
              rowData.label,
              rowData.value,
              unit: rowData.unit,
              isEven: isEven,
              isLast: isLast,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {String? unit, required bool isEven, bool isLast = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isEven ? AppColors.backgroundTint : AppColors.white,
        borderRadius: isLast ? BorderRadius.vertical(bottom: Radius.circular(16.r)) : null,
      ),
      // Neither side used to be flexible, so a long label pushed the value —
      // and its unit — straight off the right edge. The label gives way first;
      // the reading is the part nobody can afford to lose.
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyleManager.style11Medium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyleManager.style11Medium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (unit != null) ...[
                  SizedBox(width: 4.w),
                  Flexible(
                    child: Text(
                      unit,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyleManager.style9Medium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
