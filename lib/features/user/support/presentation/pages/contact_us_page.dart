import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/features/shared/conversations/presentation/pages/chat_details_page.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header ──────────────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Row(
                  children: [
                    // Back arrow (RTL → points right visually = arrow_forward_ios)
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: AppColors.black,
                        size: 20.sp,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'تواصل معنا',
                        textAlign: TextAlign.center,
                        style: TextStyleManager.heading2
                            .copyWith(color: AppColors.black),
                      ),
                    ),
                    // Spacer to balance the back arrow
                    SizedBox(width: 20.w),
                  ],
                ),
              ),

              SizedBox(height: 8.h),

              // ── Subtitle ────────────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Text(
                  'لنرافقك في رحلتك نحو جسم صحي ورشيق بخطة\nمدروسة ودعم متخصص.',
                  textAlign: TextAlign.start,
                  style: TextStyleManager.style11Medium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
              ),

              SizedBox(height: 32.h),

              // ── AI Coach Card ────────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: _ContactCard(
                  title: 'مدربك الذكي',
                  subtitle: 'جاهز للانطلاق؟ أنا معاك خطوة بخطوة 🍃',
                  image: Image.asset(
                    AppImages.ai,
                    width: 70.r,
                    height: 70.r,
                    fit: BoxFit.contain,
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChatDetailsPage(
                        title: 'مدربك الذكي',
                        isAi: true,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // ── Specialist Card ──────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: _ContactCard(
                  title: 'التحدث مع اخصائي تغذية',
                  subtitle: 'جاهز للانطلاق؟ أنا معاك خطوة بخطوة 🍃',
                  image: SvgPicture.asset(
                    SvgIcons.logo,
                    width: 70.r,
                    height: 70.r,
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChatDetailsPage(
                        title: 'أخصائي تغذية',
                        isSpecialist: true,
                      ),
                    ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Contact Card
// ─────────────────────────────────────────────────────────────────────────────
class _ContactCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget image;
  final VoidCallback onTap;

  const _ContactCard({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.backgroundTint,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.greenMint, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
        // SizedBox(width: 6.w),
            ClipOval(
              child: Container(
                width: 70.r,
                height: 70.r,
                padding: EdgeInsets.all(7.r),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.white, width: 1),
                  color: AppColors.white.withOpacity(0.7),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.17),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: image,
              ),
            ),

            SizedBox(width: 6.w),

            // Title + arrow + subtitle (column)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyleManager.style14Bold
                        .copyWith(color: AppColors.black),
                  ),

                  // « arrow row, aligned to the end on its own line
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.keyboard_double_arrow_left,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        size: 25.sp,
                        
                      ),
                    ],
                  ),

                  Text(
                    subtitle,
                    style: TextStyleManager.style10Medium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}