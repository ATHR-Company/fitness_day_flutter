import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/specialist/clients/data/models/client_progress_model.dart';

/// Presentation-only progress chart. It renders the given [data] for the
/// [selectedVisitNumber] and reports visit changes through [onSelectVisit],
/// so it can be driven by any cubit (specialist client progress or the
/// logged-in user's own progress).
class ProgressChart extends StatelessWidget {
  final ClientProgressDataModel data;
  final int selectedVisitNumber;
  final void Function(int visitNumber) onSelectVisit;

  const ProgressChart({
    super.key,
    required this.data,
    required this.selectedVisitNumber,
    required this.onSelectVisit,
  });

  @override
  Widget build(BuildContext context) {
    final chart = data.chart ?? [];
        final currentWeightVal = data.currentWeight?.value?.toString() ?? '0';
        final currentWeightUnit = data.currentWeight?.unit ?? 'clients_page.kg'.tr();

        // Find visit numbers to enable/disable arrows
        final visitNumbers = chart
            .map((e) => e.visitNumber ?? 0)
            .where((n) => n > 0)
            .toList()
          ..sort();

        final prevVisitIndex = visitNumbers.indexOf(selectedVisitNumber) - 1;
        final nextVisitIndex = visitNumbers.indexOf(selectedVisitNumber) + 1;

        final int? prevVisitNum = prevVisitIndex >= 0 && prevVisitIndex < visitNumbers.length
            ? visitNumbers[prevVisitIndex]
            : null;
        final int? nextVisitNum = nextVisitIndex >= 0 && nextVisitIndex < visitNumbers.length
            ? visitNumbers[nextVisitIndex]
            : null;

        // Get date of currently selected visit
        final selectedPoint = chart.firstWhere(
          (e) => e.visitNumber == selectedVisitNumber,
          orElse: () => ClientProgressChartPointModel(
            visitNumber: selectedVisitNumber,
            weekStart: data.visit?.weekStart,
          ),
        );
        final formattedDate = _formatDate(selectedPoint.weekStart ?? data.visit?.weekStart);

        // Calculate dynamic maxY
        double maxWeight = 80;
        if (chart.isNotEmpty) {
          final weights = chart.map((e) => e.weight ?? 0.0).where((w) => w > 0);
          if (weights.isNotEmpty) {
            maxWeight = weights.reduce((curr, next) => curr > next ? curr : next);
          }
        }
        final maxY = maxWeight + 15;

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
                      style: TextStyleManager.style11Medium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      ' $currentWeightVal $currentWeightUnit',
                      style: TextStyleManager.style11Medium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
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
                      'clients_page.visit_number'.tr(args: [selectedVisitNumber.toString()]),
                      style: TextStyleManager.style11Medium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (formattedDate.isNotEmpty)
                      Text(
                        formattedDate,
                        style: TextStyleManager.style9Medium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Directionality.of(context) == ui.TextDirection.rtl
                            ? Icons.keyboard_double_arrow_right
                            : Icons.keyboard_double_arrow_left,
                        color: prevVisitNum != null ? AppColors.primary : AppColors.divider,
                        size: 20.sp,
                      ),
                      onPressed: prevVisitNum != null
                          ? () => onSelectVisit(prevVisitNum)
                          : null,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    SizedBox(width: 8.w),
                    IconButton(
                      icon: Icon(
                        Directionality.of(context) == ui.TextDirection.rtl
                            ? Icons.keyboard_double_arrow_left
                            : Icons.keyboard_double_arrow_right,
                        color: nextVisitNum != null ? AppColors.primary : AppColors.divider,
                        size: 20.sp,
                      ),
                      onPressed: nextVisitNum != null
                          ? () => onSelectVisit(nextVisitNum)
                          : null,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16.h),
            SizedBox(
              height: 150.h,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 28.h,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.backgroundTint.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                  BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxY,
                      minY: 0,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchCallback: (FlTouchEvent event, barTouchResponse) {
                          if (!event.isInterestedForInteractions ||
                              barTouchResponse == null ||
                              barTouchResponse.spot == null) {
                            return;
                          }
                          final xVal = barTouchResponse.spot!.touchedBarGroup.x;
                          if (xVal != selectedVisitNumber && visitNumbers.contains(xVal)) {
                            onSelectVisit(xVal);
                          }
                        },
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (group) => Colors.transparent,
                          tooltipPadding: EdgeInsets.zero,
                          tooltipMargin: 4,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '${rod.toY.toStringAsFixed(1)} ${'clients_page.kg'.tr()}',
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
                            reservedSize: 28.h,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              final int valInt = value.toInt();
                              final isActive = valInt == selectedVisitNumber;
                              if (!visitNumbers.contains(valInt)) {
                                return const SizedBox.shrink();
                              }
                              final text = Text(
                                '''${'spec_mock_z'.tr()}$valInt''',
                                style: TextStyleManager.style9Medium.copyWith(
                                  color: isActive ? AppColors.primary : AppColors.textPrimary,
                                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                ),
                              );
                              if (isActive) {
                                return SideTitleWidget(
                                  meta: meta,
                                  space: 2.h,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 2.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xffD7ECD9),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: text,
                                  ),
                                );
                              }
                              return SideTitleWidget(
                                meta: meta,
                                space: 2.h,
                                child: text,
                              );
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: chart.map((point) {
                        final visitNum = point.visitNumber ?? 0;
                        final weight = point.weight ?? 0.0;
                        final isActive = visitNum == selectedVisitNumber;
                        return _buildBar(visitNum, weight, isActive);
                      }).toList(),
                    ),
                  ),
                ],
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

  String _formatDate(String? isoDate) {
    if (isoDate == null) return '';
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      return DateFormat('d MMMM yyyy').format(dt);
    } catch (_) {
      return isoDate;
    }
  }
}
