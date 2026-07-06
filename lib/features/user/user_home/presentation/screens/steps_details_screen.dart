import 'package:fitness_day/core/widgets/screen_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

// نوع النشاط — يتحكم في العنوان والوحدة والبيانات
enum ActivityType { walking, running }

class StepsDetailsScreen extends StatefulWidget {
  final ActivityType type;

  const StepsDetailsScreen({super.key, this.type = ActivityType.walking});

  @override
  State<StepsDetailsScreen> createState() => _StepsDetailsScreenState();
}

class _StepsDetailsScreenState extends State<StepsDetailsScreen> {
  // ─── Tab ───────────────────────────────────────────────────────────────────
  int _selectedTab = 0;
  final List<String> _tabs = ['يومي', 'أسبوعي', 'شهري'];

  // ─── Mock data — walking (خطوات) ─────────────────────────────────────────
  static const double _walkingCurrent = 2500;
  static const double _walkingGoal    = 5000;
  static const int    _walkingPercent = 44;
  static const String _walkingUnit    = 'خطوة';
  static const String _walkingTitle   = 'تتبع الخطوات';

  // ─── Mock data — running (كم) ─────────────────────────────────────────────
  static const double _runningCurrent = 1.52;
  static const double _runningGoal    = 3.45;
  static const int    _runningPercent = 44;
  static const String _runningUnit    = 'كم';
  static const String _runningTitle   = 'تتبع الجري';

  // ─── Shared mock ──────────────────────────────────────────────────────────
  static const _vsYesterdayPercent = 23;
  static const _calories = 50;
  static const _minutes = 30;

  bool get _isRunning => widget.type == ActivityType.running;

  double get _currentVal => _isRunning ? _runningCurrent : _walkingCurrent;
  double get _goalVal => _isRunning ? _runningGoal : _walkingGoal;
  int get _pct => _isRunning ? _runningPercent : _walkingPercent;
  String get _unit => _isRunning ? _runningUnit : _walkingUnit;
  String get _title => _isRunning ? _runningTitle : _walkingTitle;
  double get _percent => (_currentVal / _goalVal).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ── AppBar ─────────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 20.sp,
                        color: AppColors.black,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _title,
                      style: TextStyleManager.heading2.copyWith(
                        color: AppColors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 16.sp,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(width: 20.sp),
                  ],
                ),
              ),

              // ── Period tabs ────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: _PeriodTabBar(
                  tabs: _tabs,
                  selectedIndex: _selectedTab,
                  onTabChanged: (i) => setState(() => _selectedTab = i),
                ),
              ),

              SizedBox(height: 50.h),

              // ── Circular indicator ─────────────────────────────────────
              _CircularStepsIndicator(
                percent: _percent,
                currentVal: _currentVal,
                goalVal: _goalVal,
                unit: _unit,
                goalPercent: _pct,
                vsYesterdayPercent: _vsYesterdayPercent,
                isRunning: _isRunning,
              ),

              SizedBox(height: 32.h),

              // ── Daily summary ──────────────────────────────────────────
              Expanded(
                child: _DailySummaryCard(
                  distanceKm: _currentVal,
                  unit: _unit,
                  minutes: _minutes,
                  calories: _calories,
                  isWalking: !_isRunning,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Period Tab Bar
// ─────────────────────────────────────────────────────────────────────────────

class _PeriodTabBar extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  const _PeriodTabBar({
    required this.tabs,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: List.generate(tabs.length, (i) {
          final isSelected = selectedIndex == i;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTabChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                padding: EdgeInsets.symmetric(vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xffDEF4E1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.09),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                  border: isSelected
                      ? Border.all(color: AppColors.divider, width: 1)
                      : null,
                ),
                child: Text(
                  tabs[i],
                  textAlign: TextAlign.center,
                  style: TextStyleManager.style11Medium.copyWith(
                    color: isSelected ? AppColors.primary : AppColors.black,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Circular Steps Indicator
// ─────────────────────────────────────────────────────────────────────────────

class _CircularStepsIndicator extends StatelessWidget {
  final double percent;
  final double currentVal;
  final double goalVal;
  final String unit;
  final int goalPercent;
  final int vsYesterdayPercent;
  final bool isRunning;

  const _CircularStepsIndicator({
    required this.percent,
    required this.currentVal,
    required this.goalVal,
    required this.unit,
    required this.goalPercent,
    required this.vsYesterdayPercent,
    required this.isRunning,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── ring and badge ───────────────────────────────────────────
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            CircularPercentIndicator(
              radius: 115.r,
              lineWidth: 16.w,
              percent: percent,
              startAngle: 220,
              backgroundColor: AppColors.backgroundTint,
              progressColor: AppColors.greenLightAccent,
              circularStrokeCap: CircularStrokeCap.round,
              center: Container(
                padding:isRunning?EdgeInsets.all(55.w):EdgeInsets.all(45.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.backgroundTint,
                ),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // current val
                    Text(
                      isRunning
                          ? currentVal.toStringAsFixed(2)
                          : currentVal.toStringAsFixed(0),
                      style: TextStyleManager.style28Bold.copyWith(
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    // icon badge — pause for walking, play for running
                    Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isRunning ? Icons.pause : Icons.play_arrow_rounded,
                        color: AppColors.white,
                        size: 18.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    // goal text
                    Text(
                      '/ ${isRunning ? goalVal.toStringAsFixed(2) : goalVal.toStringAsFixed(0)} $unit',
                      style: TextStyleManager.style11Medium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── goal percent badge ─────────────────────────────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 7.h,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.greenMint, width: 1.r),
                    gradient: AppColors.timeRemainingGradient,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '$goalPercent% من هدفك',
                    style: TextStyleManager.style11Medium.copyWith(
                      color: AppColors.greenDarkAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 20.h),

        // ── vs yesterday ──────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.arrow_upward_rounded,
              color: AppColors.primary,
              size: 20.sp,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(width: 4.w),
            Text(
              '$vsYesterdayPercent% من اليوم الماضي',
              style: TextStyleManager.dataCard.copyWith(
                color: AppColors.textSecondary,
                fontSize: 10.sp,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Daily Summary Card
// ─────────────────────────────────────────────────────────────────────────────

class _DailySummaryCard extends StatelessWidget {
  final double distanceKm;
  final String unit;
  final int minutes;
  final int calories;
  final bool isWalking;

  const _DailySummaryCard({
    required this.distanceKm,
    required this.unit,
    required this.minutes,
    required this.calories,
    this.isWalking = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── title ────────────────────────────────────────────────────────
          Text(
            'ملخص اليوم',
            // textAlign: TextAlign.right,
            style: TextStyleManager.heading3.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 19.h),

          // ── card ─────────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
            decoration: BoxDecoration(
              gradient: AppColors.cardGradient,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: AppColors.borderGrey, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // calories
                _SummaryItem(
                  icon: const Icon(
                    Icons.local_fire_department_rounded,
                    color: Colors.deepOrangeAccent,
                    size: 26,
                  ),
                  label: 'عدد السعرات',
                  value: '$calories',
                  unit: 'كالوري',
                  valueColor: AppColors.primary,
                ),
                // time
                _SummaryItem(
                  icon: Icon(
                    Icons.access_time_filled_rounded,
                    color: AppColors.surfaceGray,
                    size: 26,
                  ),
                  label: 'الوقت المستغرق',
                  value: '$minutes',
                  unit: 'دقيقة',
                  valueColor: AppColors.primary,
                ),
                // distance
                _SummaryItem(
                  icon: const Icon(
                    Icons.location_on_rounded,
                    color: Colors.pinkAccent,
                    size: 26,
                  ),
                  label: 'المسافة',
                  value: isWalking
                      ? distanceKm.toStringAsFixed(0)
                      : distanceKm.toStringAsFixed(2),
                  unit: unit,
                  valueColor: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Summary Item
// ─────────────────────────────────────────────────────────────────────────────

class _SummaryItem extends StatelessWidget {
  final Widget icon;
  final String label;
  final String value;
  final String unit;
  final Color? valueColor;

  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        SizedBox(height: 6.h),
        Text(
          label,
          style: TextStyleManager.dataCard.copyWith(
            color: AppColors.textSecondary,
            fontSize: 10.sp,
          ),
        ),
        SizedBox(height: 4.h),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: TextStyleManager.style16Bold.copyWith(
                  color: valueColor ?? AppColors.black,
                ),
              ),
              TextSpan(
                text: ' $unit',
                style: TextStyleManager.heading2.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
