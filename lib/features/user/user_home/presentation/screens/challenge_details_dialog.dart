import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../core/constant/app_assets.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import 'challenges_screen.dart';

class ChallengeDetailsDialog extends StatefulWidget {
  final ChallengeModel challenge;

  const ChallengeDetailsDialog({super.key, required this.challenge});

  @override
  State<ChallengeDetailsDialog> createState() => _ChallengeDetailsDialogState();
}

class _ChallengeDetailsDialogState extends State<ChallengeDetailsDialog> {
  bool _isDescriptionSelected = true;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F4EA), // Light green
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.close_rounded,
                      color: AppColors.primary,
                      size: 30.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'تفاصيل التحدي',
                    style: TextStyleManager.heading2.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(width: 28.sp), // Balance the close icon
                ],
              ),
            ),

            // Image and Tab Switcher
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                Image.network(
                  widget.challenge.imageUrl ??
                      "https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=400",
                  height: 180.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                // Tab switcher
                Positioned(
                  bottom: -24.h,
                  child: Container(
                    width: 260.w,
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(24.r),
                      border: Border.all(color: AppColors.primary, width: 0.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _isDescriptionSelected = true),
                            child: Container(
                              decoration: BoxDecoration(
                                color: _isDescriptionSelected
                                    ? const Color(0xFFE6F4EA)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(24.r),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'الوصف',
                                style: TextStyleManager.style11Medium.copyWith(
                                  color: _isDescriptionSelected
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _isDescriptionSelected = false),
                            child: Container(
                              decoration: BoxDecoration(
                                color: !_isDescriptionSelected
                                    ? const Color(0xFFE6F4EA)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(24.r),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'القواعد',
                                style: TextStyleManager.style11Medium.copyWith(
                                  color: !_isDescriptionSelected
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (_isDescriptionSelected) ...[
              SizedBox(height: 40.h),
              // Icon
              Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Image.asset(
                    AppImages.challenge_cap,
                    width: 40.w,
                    height: 40.w,
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Goal
              Text(
                'الهدف : ${widget.challenge.goal}',
                style: TextStyleManager.style13Medium.copyWith(
                  color: AppColors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12.h),

              // Dates
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _DateBadge(label: widget.challenge.endDate, isEnd: true),
                  SizedBox(width: 32.w),
                  _DateBadge(label: widget.challenge.startDate, isEnd: false),
                ],
              ),
              SizedBox(height: 24.h),

              Text(
                'الوصف :',
                style: TextStyleManager.style11Medium.copyWith(
                  color: AppColors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Text(
                  'تحدى نفسك اليوم وامشي 15,000 خطوة! هذا التحدي\nيساعدك على زيادة نشاطك اليومي، تحسين صحتك\nالبدنية، وحرق السعرات بطريقة ممتعة وسهلة. خطوة\nخطوة، ستشعر بالنشاط والحيوية طوال اليوم.',
                  textAlign: TextAlign.center,
                  style: TextStyleManager.style11Medium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
              SizedBox(height: 32.h),

              // Next Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: action for next
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: Size(double.infinity, 50.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'التالى',
                    style: TextStyleManager.style13Medium.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ] else ...[
              SizedBox(height: 32.h),
              _buildRuleItem(
                'ابدأ من الآن كل خطوة تُحسب بدءًا من اللحظة التي تبدأ فيها التحدي.',
              ),
              _buildRuleItem(
                'تتبع الخطوات و استخدم هاتفك أو الساعة الذكية لتسجيل خطواتك.',
              ),
              _buildRuleItem(
                'يمكن أخذ فترات راحة قصيرة أثناء المشي، المهم الوصول للهدف النهائي.',
              ),
              _buildRuleItem(
                'عند الوصول لـ 15,000 خطوة، ستحصل على لقد أكملت تحدي المشي اليوم!',
              ),
              _buildRuleItem(
                'إذا أكملت التحدي 2 أيام متتالية، يحصل على نقاط مضاعفة',
              ),
              SizedBox(height: 32.h),

              // Join Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: action for join
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: Size(double.infinity, 50.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'الانضمام',
                    style: TextStyleManager.style13Medium.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleItem(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 2.h),
            child: Icon(
              Icons.radio_button_checked,
              color: AppColors.primary,
              size: 18.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: TextStyleManager.style10Medium.copyWith(
                color: AppColors.textPrimary,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
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
