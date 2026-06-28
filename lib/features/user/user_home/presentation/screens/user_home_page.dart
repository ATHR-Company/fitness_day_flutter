import 'dart:ui' as ui;
import 'package:fitness_day/features/user/user_home/presentation/widgets/user_categories.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../core/constant/app_assets.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_shadows.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../widgets/home_header.dart';
import '../widgets/section_header.dart';

class UserHomePage extends StatelessWidget {
  const UserHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        // backgroundColor: const Color(0xFFF4FAF4),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(0.0),
          child: AppBar(
            elevation: 0,
            backgroundColor: const Color(0xFFEAF6EA),
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.dark,
            ),
          ),
        ),
        endDrawer: const AppDrawer(),
        body: Stack(
          children: [
            // Background split: light green top, off-white bottom
          
            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── 1. Header ───────────────────────────────────────────
                    const userHomeHeader(),

                    SizedBox(height: 12.h),

                    // ── 2. Subscription Banner ──────────────────────────────
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: const _SubscriptionBanner(),
                    ),

                    SizedBox(height: 16.h),

                    // ── 3. Hero Banner ──────────────────────────────────────
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: const _HeroBanner(),
                    ),

                    SizedBox(height: 20.h),

                    // ── 4. Categories Row ───────────────────────────────────
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: const UserCategories(),
                    ),

                    SizedBox(height: 20.h),

                    // ── 5. Stat Cards Row ───────────────────────────────────
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: const _StatCardsRow(),
                    ),

                    SizedBox(height: 16.h),

                    // ── 6. Current Weight Card ──────────────────────────────
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: const _CurrentWeightCard(),
                    ),

                    SizedBox(height: 16.h),

                    // ── 7. Today's Tasks Section ────────────────────────────
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: SectionHeader(
                        title: "home.todays_tasks".tr(),
                        onMorePressed: () {},
                      ),
                    ),

                    SizedBox(height: 12.h),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: const _TodayTasksList(),
                    ),

                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Subscription Banner
// ─────────────────────────────────────────────────────────────────────────────
class _SubscriptionBanner extends StatelessWidget {
  const _SubscriptionBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7CD588), Color(0xFFE6FFE9), Color(0xFF7CD588)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(35.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Heart icon
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            width: 30.w,
            height: 30.w,
            child: SvgPicture.asset(SvgIcons.diamond),
          ),
          // End date badge on the right (RTL → visually on right)

          // Subscribe text (center)
          Expanded(
            child: Text(
              "انت الأن مشترك فى باقة صحى ",
              style: TextStyleManager.style10Medium.copyWith(
                color: AppColors.greenJungle,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
            margin: EdgeInsets.all(0.r),
            height: 48.h,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(35.r),
            ),
            child: Center(
              child: Column(
                children: [
                  Text(
                    'تاريخ الانتهاء',
                    textAlign: TextAlign.center,
                    style: TextStyleManager.style9Medium.copyWith(
                      color: AppColors.white,

                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    '2026 / 16 / 7',
                    textAlign: TextAlign.center,
                    style: TextStyleManager.style9Medium.copyWith(
                      color: AppColors.white,

                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero Banner
// ─────────────────────────────────────────────────────────────────────────────
class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: Stack(
        children: [
          // Green radial background
          Container(
            height: 180.h,
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.0,
                colors: [
                  Color(0xFFB8F5BE),
                  Color(0xFF7CD588),
                  Color(0xFF00A417),
                ],
              ),
            ),
          ),

          // Fire / logo icon top-right area
          PositionedDirectional(
            top: 12.h,
            start: 16.w,
            child: Icon(
              Icons.local_fire_department,
              color: AppColors.primary,
              size: 28.sp,
            ),
          ),

          // Bottom motivational text bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF00A417), Color(0xFF29B63D)],
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                ),
              ),
              child: Text(
                '🏋️ التزم بخطتك الغذائية ، واقترب كل يوم من هدفك 🔥',
                style: TextStyleManager.style11Medium.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stat Cards Row  (عدد الزيارات  +  زيارتك القادمة)
// ─────────────────────────────────────────────────────────────────────────────
class _StatCardsRow extends StatelessWidget {
  const _StatCardsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            iconPath: SvgIcons.calendar,
            title: 'زيارتك القادمة',
            value: '4/8/2026',
            valueColor: AppColors.primary,
          ),
        ),

        SizedBox(width: 12.w),
        Expanded(
          child: _StatCard(
            iconPath: SvgIcons.visitsHistory,
            title: 'عدد الزيارات',
            value: '2',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String iconPath;
  final String title;
  final String value;
  final Color? valueColor;

  const _StatCard({
    required this.iconPath,
    required this.title,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
      decoration: BoxDecoration(
        // gradient: AppColors.cardGradient,
        color: Color(0xffEFFBF1
),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: AppShadows.primaryShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: AppColors.backgroundTint,
              shape: BoxShape.circle,
            ),
            padding: EdgeInsets.all(12.r),
            child: SvgPicture.asset(
              iconPath,
              colorFilter: const ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            title,
            style: TextStyleManager.style10Medium.copyWith(
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyleManager.style14Bold.copyWith(
              color: valueColor ?? AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Current Weight Card  (وزنك الحالي)
// ─────────────────────────────────────────────────────────────────────────────
class _CurrentWeightCard extends StatelessWidget {
  const _CurrentWeightCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: AppShadows.primaryShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'وزنك الحالي',
                style: TextStyleManager.style14Bold.copyWith(
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              // Icon
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: AppColors.backgroundTint,
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(10.r),
                child: SvgPicture.asset(
                  SvgIcons.weight,
                  colorFilter: const ColorFilter.mode(
                    AppColors.primary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              // Weight label + value
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'وزنك الحالي',
                    style: TextStyleManager.style10Medium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '57.8',
                        style: TextStyleManager.style28Bold.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'كجم',
                        style: TextStyleManager.style11Medium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              // Tag / badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.greenMint,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'طبيعي',
                  style: TextStyleManager.style9Medium.copyWith(
                    color: AppColors.greenForest,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Today's Tasks List  (مهام اليوم)
// ─────────────────────────────────────────────────────────────────────────────
class _TodayTasksList extends StatelessWidget {
  const _TodayTasksList();

  @override
  Widget build(BuildContext context) {
    final tasks = [
      _TaskData(
        icon: SvgIcons.diet,
        title: 'خطة التغذية',
        subtitle: 'تناول وجبة الإفطار',
        time: '8:00 صباحاً',
        done: true,
      ),
      _TaskData(
        icon: SvgIcons.workout,
        title: 'تمرين اليوم',
        subtitle: 'تمرين الجزء العلوي',
        time: '10:00 صباحاً',
        done: false,
      ),
    ];

    return Column(
      children: tasks
          .map(
            (task) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _TaskCard(task: task),
            ),
          )
          .toList(),
    );
  }
}

class _TaskData {
  final String icon;
  final String title;
  final String subtitle;
  final String time;
  final bool done;

  const _TaskData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.done,
  });
}

class _TaskCard extends StatelessWidget {
  final _TaskData task;

  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: AppShadows.primaryShadow,
      ),
      child: Row(
        children: [
          // Icon circle
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: AppColors.backgroundTint,
              shape: BoxShape.circle,
            ),
            padding: EdgeInsets.all(12.r),
            child: SvgPicture.asset(
              task.icon,
              colorFilter: const ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyleManager.style13Medium.copyWith(
                    color: AppColors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  task.subtitle,
                  style: TextStyleManager.style10Medium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      task.time,
                      style: TextStyleManager.style9Medium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Done check
          Icon(
            task.done
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked,
            color: task.done ? AppColors.primary : AppColors.divider,
            size: 24.sp,
          ),
        ],
      ),
    );
  }
}
