import 'package:fitness_day/core/widgets/screen_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/constant/app_assets.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import 'create_challenge_screen.dart';
import 'package:fitness_day/core/widgets/app_image.dart';

// ─── Model ────────────────────────────────────────────────────────────────────
class ChallengeModel {
  final String title;
  final String goal;
  final String startDate;
  final String endDate;
  final int participants;
  final String? imageUrl;
  final bool isActive;

  const ChallengeModel({
    required this.title,
    required this.goal,
    required this.startDate,
    required this.endDate,
    required this.participants,
    this.imageUrl,
    this.isActive = false,
  });
}

// ─── Mock data ────────────────────────────────────────────────────────────────
const _mockActiveChallenges = <ChallengeModel>[
  ChallengeModel(
    title: 'تحدي يوم الرشاقة',
    goal: '15000 خطوة خلال يوم',
    startDate: '22/2/2026',
    endDate: '23/2/2026',
    participants: 1234,
    isActive: true,
  ),
];

const _mockSuggestedChallenges = <ChallengeModel>[
  ChallengeModel(
    title: 'انقاص الوزن',
    goal: 'انقاص 2 كيلو في اسبوع',
    startDate: '21/2/2026',
    endDate: '28/2/2026',
    participants: 100,
  ),
  ChallengeModel(
    title: 'انقاص الوزن',
    goal: 'انقاص 2 كيلو في اسبوع',
    startDate: '21/2/2026',
    endDate: '28/2/2026',
    participants: 100,
  ),
  ChallengeModel(
    title: 'انقاص الوزن',
    goal: 'انقاص 2 كيلو في اسبوع',
    startDate: '21/2/2026',
    endDate: '28/2/2026',
    participants: 100,
  ),
  ChallengeModel(
    title: 'انقاص الوزن',
    goal: 'انقاص 2 كيلو في اسبوع',
    startDate: '21/2/2026',
    endDate: '28/2/2026',
    participants: 100,
  ),
];

// ─── Screen ───────────────────────────────────────────────────────────────────
class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  final bool _hasActiveChallenges = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: _hasActiveChallenges ? _buildWithChallenges() : _buildEmptyState(),
        ),
      ),
    );
  }

  // ─── AppBar ────────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back_ios_rounded,
              size: 20.sp,
              color: AppColors.black,
            ),
          ),
          const Spacer(),
          Text(
            'التحديات',
            style: TextStyleManager.heading2.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
            ),
          ),
          const Spacer(),
          SizedBox(width: 50.sp),
        ],
      ),
    );
  }

  // ─── Empty State ───────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Column(
      children: [
        _buildAppBar(),
        SizedBox(height: 30.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: _buildAddChallengeButton(),
        ),
        SizedBox(height: 80.h),
        AppImage(
          AppImages.challenge_cap,
          width: 200.w,
          height: 170.w,
          fit: BoxFit.contain,
        ),
        SizedBox(height: 28.h),
        Text(
          'لا توجد تحديات نشطة حالياً',
          style: TextStyleManager.heading3.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 17.sp,
          ),
        ),
        SizedBox(height: 12.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Text(
            "يمكنك تصميم تحديك الخاص، أو الانضمام إلى أحد التحديات العامة ومنافسة باقي المشتركين للوصول إلى هدفك بشكل أسرع وأكثر حماساً!",
            textAlign: TextAlign.center,
            style: TextStyleManager.sideBarText.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12.sp,
              // height: 1.7,
            ),
          ),
        ),
      ],
    );
  }

  // ─── Full Content ──────────────────────────────────────────────────────────
  Widget _buildWithChallenges() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildAppBar(),
        SizedBox(height: 16.h),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Active card ─────────────────────────────────────────
                if (_mockActiveChallenges.isNotEmpty) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: _ActiveChallengeCard(
                      challenge: _mockActiveChallenges.first,
                      onJoin: () {},
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],

                // ── Add challenge button ─────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: _buildAddChallengeButton(),
                ),
                SizedBox(height: 28.h),

                // ── Suggested section header ─────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'التحديات المقترحة',
                        style: TextStyleManager.heading3.copyWith(
                          color: AppColors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                        ),
                        // textAlign: TextAlign.right,
                      ),
                      SizedBox(height: 7.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          AppImage(
                            SvgIcons.muscle,
                            width: 16.w,
                            height: 16.w,
                            color: AppColors.black,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'تحديات بناء على اهتمامك',
                            style: TextStyleManager.style9Medium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),

                // ── Suggested list ───────────────────────────────────────
                ...List.generate(
                  _mockSuggestedChallenges.length,
                  (i) => Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 6.h,
                    ),
                    child: _SuggestedChallengeCard(
                      challenge: _mockSuggestedChallenges[i],
                      onJoin: () {},
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Add Challenge Button ───────────────────────────────────────────────────
  Widget _buildAddChallengeButton() {
    return Container(
      // height: 50.h,
      padding: EdgeInsets.symmetric(vertical: 10.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.4),
          width: 1,
        ),
        gradient: AppColors.cardGradient,
      ),
      child: Row(
        children: [
          SizedBox(width: 16.w),
          Text(
            'إضافة تحدي جديد',
            style: TextStyleManager.style11Medium.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          // Add button (left in RTL = visually right)
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateChallengeScreen()),
              );
            },
            child: Container(
              margin: EdgeInsets.all(6.r),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'إضافة',
                    style: TextStyleManager.style11Medium.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Directionality.of(context) == TextDirection.rtl
                        ? Icons.keyboard_double_arrow_left_rounded
                        : Icons.keyboard_double_arrow_right_rounded,
                    color: AppColors.white,
                    size: 16.sp,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 10.w),
        ],
      ),
    );
  }
}

// ─── Active Challenge Card ─────────────────────────────────────────────────────
class _ActiveChallengeCard extends StatelessWidget {
  final ChallengeModel challenge;
  final VoidCallback? onJoin;

  const _ActiveChallengeCard({required this.challenge, this.onJoin});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.borderGrey, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Image ──────────────────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            child: challenge.imageUrl != null
                ? AppImage(
                    challenge.imageUrl!,
                    height: 180.h,
                    fit: BoxFit.cover,
                  )
                : _placeholderImage(),
          ),

          // ── Body ───────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row + participants
                Row(
                  children: [
                    // Title
                    Text(
                      challenge.title,
                      style: TextStyleManager.style13Medium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    // Participants badge
                    Row(
                      children: [
                        AppImage(
                          SvgIcons.usersGroup,
                          width: 16.w,
                          height: 16.w,
                          color: AppColors.primary,
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
                  ],
                ),
                SizedBox(height: 6.h),

                // Goal
                Text(
                  'الهدف  ${challenge.goal}',
                  style: TextStyleManager.text2.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 11.sp,
                  ),
                  textAlign: TextAlign.right,
                ),
                SizedBox(height: 10.h),

                // Dates + join button
                Row(
                  children: [
                    _DateBadge(label: challenge.startDate, isEnd: false),
                    SizedBox(width: 16.w),
                    // Date badges
                    _DateBadge(label: challenge.endDate, isEnd: true),

                    const Spacer(),
                    GestureDetector(
                      onTap: onJoin,
                      child: Container(
                        child: Icon(
                          Directionality.of(context) == TextDirection.rtl
                              ? Icons.keyboard_double_arrow_left_rounded
                              : Icons.keyboard_double_arrow_right_rounded,
                          color: AppColors.primary,
                          size: 25.sp,
                        ),
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

  Widget _placeholderImage() {
    return Container(
      height: 180.h,
      width: double.infinity,
      color: AppColors.backgroundTint,
      child: AppImage(
        "https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=400",
        fit: BoxFit.cover,
      ),
    );
  }
}

// ─── Suggested Challenge Card ──────────────────────────────────────────────────
class _SuggestedChallengeCard extends StatelessWidget {
  final ChallengeModel challenge;
  final VoidCallback? onJoin;

  const _SuggestedChallengeCard({required this.challenge, this.onJoin});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Color(0xFFF2F5FA),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderGrey, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // ── Trophy icon ───────────────────────────────────────────────
              Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: AppImage(
                    AppImages.challenge_cap,
                    width: 40.w,
                    height: 40.w,
                    // colorFilter: const ColorFilter.mode(
                    //   Colors.white,
                    //   BlendMode.srcIn,
                    // ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              // ── Content ───────────────────────────────────────────────────
              Expanded(
                child: Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title + participants
                        Row(
                          children: [
                            // Title
                            Text(
                              challenge.title,
                              style: TextStyleManager.style13Medium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 14.w),

                            // Participants
                            Text(
                              '${challenge.participants}',
                              style: TextStyleManager.style10Medium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            AppImage(
                              SvgIcons.usersGroup,
                              width: 14.w,
                              height: 14.w,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),

                        // Goal
                        Text(
                          challenge.goal,
                          style: TextStyleManager.style10Medium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        SizedBox(height: 8.h),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // SizedBox(width: 16.w),
                        _DateBadge(label: challenge.endDate, isEnd: true),

                        _DateBadge(label: challenge.startDate, isEnd: false),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Join arrow (left in RTL) ──────────────────────────────────
              GestureDetector(
                onTap: onJoin,
                child: Container(
                  width: 38.w,
                  height: 38.w,

                  child: Icon(
                    Directionality.of(context) == TextDirection.rtl
                        ? Icons.keyboard_double_arrow_left_rounded
                        : Icons.keyboard_double_arrow_right_rounded,
                    color: AppColors.primary,
                    size: 22.sp,
                  ),
                ),
              ),

              // SizedBox(width: 10.w),
            ],
          ),
          SizedBox(height: 10.h),
          // Date badges
        ],
      ),
    );
  }
}

// ─── Date Badge ────────────────────────────────────────────────────────────────
class _DateBadge extends StatelessWidget {
  final String label;
  final bool isEnd;

  const _DateBadge({required this.label, required this.isEnd});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: AppColors.textSecondary, width: 1),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(
            isEnd ? 'END' : 'START',
            style: TextStyleManager.style7Medium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextStyleManager.style8Medium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
