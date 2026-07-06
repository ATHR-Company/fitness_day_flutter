import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/entities/task_data.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/screen_background.dart';
import 'package:fitness_day/core/widgets/task_card.dart';
import 'package:fitness_day/features/user/challenges/domain/entities/challenge_model.dart';
import 'package:fitness_day/features/user/challenges/presentation/widgets/date_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:percent_indicator/percent_indicator.dart';

// ─── Challenge Type ───────────────────────────────────────────────────────────

enum ChallengeType { steps, exercise }

// ─── Screen ───────────────────────────────────────────────────────────────────

class ChallengeActiveScreen extends StatefulWidget {
  final ChallengeModel challenge;
  final ChallengeType challengeType;

  const ChallengeActiveScreen({
    super.key,
    required this.challenge,
    this.challengeType = ChallengeType.exercise,
  });

  @override
  State<ChallengeActiveScreen> createState() => _ChallengeActiveScreenState();
}

class _ChallengeActiveScreenState extends State<ChallengeActiveScreen> {
  void _showOptionsSheet(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.25),
      builder: (_) => Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 24.h),
        backgroundColor: Colors.transparent,
        child: const _ChallengeOptionsSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ── AppBar ────────────────────────────────────────────
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
                      'تفاصيل التحدي',
                      style: TextStyleManager.heading2.copyWith(
                        color: AppColors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 16.sp,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _showOptionsSheet(context),
                      child: Padding(
                        padding: EdgeInsets.all(8.w),
                        child: Icon(
                          Icons.more_vert_rounded,
                          size: 22.sp,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // ── Content ───────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _HeroSection(imageUrl: widget.challenge.imageUrl),
                      SizedBox(height: 24.h),
                      _ChallengeHeader(challenge: widget.challenge),
                      SizedBox(height: 24.h),
                      if (widget.challengeType == ChallengeType.steps)
                        _StepsContent(challenge: widget.challenge)
                      else
                        _ExerciseContent(challenge: widget.challenge),
                      SizedBox(height: 32.h),
                      const _PreviousAchievements(),
                      SizedBox(height: 32.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Hero Section ─────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  final String? imageUrl;

  static const _fallback =
      'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=400';

  const _HeroSection({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        Image.network(
          imageUrl ?? _fallback,
          height: 200.h,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, e, __) =>
              Image.network(_fallback, height: 200.h, fit: BoxFit.cover),
        ),
        Positioned(
          bottom: -15.h,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 7.h),
            decoration: BoxDecoration(
              gradient: AppColors.timeRemainingGradient,
              border: Border.all(color: AppColors.greenMint, width: 1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              'لقد حققت  44% من التحدي',
              style: TextStyleManager.style11Medium.copyWith(
                color: AppColors.greenDarkAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Challenge Header Info ────────────────────────────────────────────────────

class _ChallengeHeader extends StatelessWidget {
  final ChallengeModel challenge;

  const _ChallengeHeader({required this.challenge});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  challenge.title,
                  style: TextStyleManager.style13Medium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
              ),
              SvgPicture.asset(
                SvgIcons.usersGroup,
                width: 16.w,
                height: 16.w,
                colorFilter: const ColorFilter.mode(
                  AppColors.primary,
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(width: 4.w),
              Text(
                '${challenge.participants}',
                style: TextStyleManager.style11Medium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            'الهدف : ${challenge.goal}',
            style: TextStyleManager.style10Medium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DateBadge(label: challenge.endDate, isEnd: true),
              SizedBox(width: 16.w),
              DateBadge(label: challenge.startDate, isEnd: false),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEPS CONTENT
// ─────────────────────────────────────────────────────────────────────────────

class _StepsContent extends StatelessWidget {
  final ChallengeModel challenge;

  static const double _current = 2500;
  static const double _goal = 5000;
  static const int _pct = 44;
  static const int _vsYesterday = 23;
  static const int _calories = 50;
  static const int _minutes = 30;

  const _StepsContent({required this.challenge});

  double get _percent => (_current / _goal).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 8.h),
        _StepsCircularIndicator(
          percent: _percent,
          current: _current,
          goal: _goal,
          unit: 'خطوة',
          goalPercent: _pct,
          vsYesterday: _vsYesterday,
        ),
        SizedBox(height: 32.h),
      
      ],
    );
  }
}

class _StepsCircularIndicator extends StatelessWidget {
  final double percent;
  final double current;
  final double goal;
  final String unit;
  final int goalPercent;
  final int vsYesterday;

  const _StepsCircularIndicator({
    required this.percent,
    required this.current,
    required this.goal,
    required this.unit,
    required this.goalPercent,
    required this.vsYesterday,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
                padding: EdgeInsets.all(45.w),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.backgroundTint,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      current.toStringAsFixed(0),
                      style: TextStyleManager.style28Bold.copyWith(
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: AppColors.white,
                        size: 18.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '/ ${goal.toStringAsFixed(0)} $unit',
                      style: TextStyleManager.style11Medium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
                    border: Border.all(color: AppColors.greenMint, width: 1),
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
      ],
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// EXERCISE CONTENT
// ─────────────────────────────────────────────────────────────────────────────

class _ExerciseContent extends StatelessWidget {
  final ChallengeModel challenge;

  const _ExerciseContent({required this.challenge});

  static final _weekDays = [
    _DayData(label: 'السبت', date: 15, isDone: true),
    _DayData(label: 'الأحد', date: 16, isDone: true),
    _DayData(label: 'الاثنين', date: 16, isToday: true),
    _DayData(label: 'الثلاثاء', date: 17),
    _DayData(label: 'الأربعاء', date: 18),
    _DayData(label: 'الخميس', date: 19),
    _DayData(label: 'الجمعة', date: 20),
  ];

  static final _mockTask = TaskData(
    imagePath: AppImages.challenge_cap,
    title: 'تمرين اليوم',
    description: 'اليوم الثالث من التحدي',
    time: '',
    extraLabel: 'ابدأ الآن',
    extraUnit: '',
    extraIcon: null,
    done: false,
    onDetailsPressed: () {},
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WeekCalendar(days: _weekDays),
          SizedBox(height: 24.h),
          _TodayExerciseCard(task: _mockTask),
        ],
      ),
    );
  }
}

// ─── Week Calendar ────────────────────────────────────────────────────────────

class _DayData {
  final String label;
  final int date;
  final bool isToday;
  final bool isDone;

  const _DayData({
    required this.label,
    required this.date,
    this.isToday = false,
    this.isDone = false,
  });
}

class _WeekCalendar extends StatelessWidget {
  final List<_DayData> days;

  const _WeekCalendar({required this.days});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((d) => _DayCell(data: d)).toList(),
    );
  }
}

class _DayCell extends StatelessWidget {
  final _DayData data;

  const _DayCell({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          data.label,
          style: TextStyleManager.style9Medium.copyWith(
            color: data.isToday ? AppColors.primary : AppColors.textSecondary,
            fontWeight: data.isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        SizedBox(height: 6.h),
        if (data.isDone)
          Container(
            width: 32.w,
            height: 32.w,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              color: AppColors.white,
              size: 18.sp,
            ),
          )
        else if (data.isToday)
          Container(
            width: 32.w,
            height: 32.w,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${data.date}',
                style: TextStyleManager.style11Medium.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        else
          Container(
            width: 32.w,
            height: 32.w,
            alignment: Alignment.center,
            child: Text(
              '${data.date}',
              style: TextStyleManager.style11Medium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Today Exercise Card ──────────────────────────────────────────────────────

class _TodayExerciseCard extends StatelessWidget {
  final TaskData task;

  const _TodayExerciseCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'تمرين اليوم',
              style: TextStyleManager.heading3.copyWith(
                color: AppColors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              Icons.calendar_month_outlined,
              size: 16.sp,
              color: AppColors.textSecondary,
            ),
            SizedBox(width: 4.w),
            Text(
              'اليوم الثالث من التحدي',
              style: TextStyleManager.style10Medium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.greenMint, width: 1),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'اضغط هنا لبداية تمرين اليوم',
                  style: TextStyleManager.style11Medium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'ابدأ الآن',
                      style: TextStyleManager.style11Medium.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.keyboard_double_arrow_left_rounded,
                      color: AppColors.white,
                      size: 16.sp,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        TaskCard(task: task, plainBackground: true),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PREVIOUS ACHIEVEMENTS
// ─────────────────────────────────────────────────────────────────────────────

class _PreviousAchievements extends StatelessWidget {
  const _PreviousAchievements();

  List<TaskData> _buildAchievements(BuildContext context) => [
    TaskData(
      imagePath: SvgIcons.waterBorder,
      isSvgImage: true,
      title: 'home.hydration_title'.tr(),
      time: 'home.hydration_all_day'.tr(),
      description: 'home.hydration_desc'.tr(),
      extraLabel: '2.50 / 2.50',
      extraUnit: 'home.water_unit'.tr(),
      extraIcon: null,
      done: true,
    ),
    TaskData(
      imagePath: SvgIcons.waterBorder,
      isSvgImage: true,
      title: 'home.hydration_title'.tr(),
      time: 'home.hydration_all_day'.tr(),
      description: 'home.hydration_desc'.tr(),
      extraLabel: '2.50 / 2.50',
      extraUnit: 'home.water_unit'.tr(),
      extraIcon: null,
      done: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final achievements = _buildAchievements(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                Text(
                'انجازات سابقة',
                style: TextStyleManager.heading3.copyWith(
                  color: AppColors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    Text(
                      'المزيد',
                      style: TextStyleManager.style11Medium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.keyboard_double_arrow_left_rounded,
                      color: AppColors.primary,
                      size: 20.sp,
                    ),
                  ],
                ),
              ),
            
            ],
          ),
          SizedBox(height: 12.h),
          ...achievements.map(
            (task) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: TaskCard(task: task, plainBackground: true),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CHALLENGE OPTIONS BOTTOM SHEET
// ─────────────────────────────────────────────────────────────────────────────

class _ChallengeOptionsSheet extends StatelessWidget {
  const _ChallengeOptionsSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.greenMint, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _OptionItem(label: 'ابلاغ', onTap: () => Navigator.pop(context)),
          Divider(height: 1, color: AppColors.divider),
          _OptionItem(label: 'مشاركة', onTap: () => Navigator.pop(context)),
          Divider(height: 1, color: AppColors.divider),
          _OptionItem(
            label: 'انهاء التحدي',
            onTap: () => Navigator.pop(context),
            isDestructive: true,
          ),
        ],
      ),
    );
  }
}

class _OptionItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _OptionItem({
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 18.h),
        child: Center(
          child: Text(
            label,
            style: TextStyleManager.style13Medium.copyWith(
              color: isDestructive ? AppColors.error : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
