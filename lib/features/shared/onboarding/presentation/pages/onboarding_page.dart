import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/routes/app_routes.dart';
import 'package:fitness_day/generated/locale_keys.g.dart';
import 'package:fitness_day/features/shared/onboarding/data/models/onboarding_content.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int _currentIndex = 0;

  late final List<OnboardingContent> _contents;

  @override
  void initState() {
    super.initState();
    _contents = [
      OnboardingContent(
        imagePath: 'assets/images/onboarding1.png',
        title: LocaleKeys.onboarding_title_1.tr(),
        subtitle: LocaleKeys.onboarding_subtitle_1.tr(),
      ),
      OnboardingContent(
        imagePath: 'assets/images/onboarding2.png',
        title: LocaleKeys.onboarding_title_2.tr(),
        subtitle: LocaleKeys.onboarding_subtitle_2.tr(),
      ),
      OnboardingContent(
        imagePath: 'assets/images/onboarding3.png',
        title: LocaleKeys.onboarding_title_3.tr(),
        subtitle: LocaleKeys.onboarding_subtitle_3.tr(),
      ),
    ];
  }

  void _nextPage() {
    if (_currentIndex < _contents.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      _finishOnboarding();
    }
  }

  void _prevPage() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    }
  }

  void _finishOnboarding() {
    // Navigate to Login screen
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.splashBackgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip Button
              Align(
                alignment: AlignmentDirectional.topEnd,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                  child: InkWell(
                    onTap: _finishOnboarding,
                    borderRadius: BorderRadius.circular(20.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            LocaleKeys.onboarding_skip.tr().replaceAll('»', '').trim(),
                            style: TextStyleManager.style14Medium.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Icon(
                            Directionality.of(context) == ui.TextDirection.rtl
                                ? Icons.keyboard_double_arrow_left_rounded
                                : Icons.keyboard_double_arrow_right_rounded,
                            size: 16.w,
                            color: AppColors.textPrimary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Animated Content
              Expanded(
                child: GestureDetector(
                  onHorizontalDragEnd: (details) {
                    final isRTL = Directionality.of(context) == ui.TextDirection.rtl;
                    
                    if (details.primaryVelocity! < 0) {
                      // Swiping Left (Right to Left)
                      isRTL ? _prevPage() : _nextPage();
                    } else if (details.primaryVelocity! > 0) {
                      // Swiping Right (Left to Right)
                      isRTL ? _nextPage() : _prevPage();
                    }
                  },
                  child: Container(
                    color: Colors.transparent, // Ensure gesture detector captures touches
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Image & Indicators
                        Expanded(
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 500),
                                transitionBuilder: (child, animation) => FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                                child: Image.asset(
                                  _contents[_currentIndex].imagePath,
                                  key: ValueKey<int>(_currentIndex),
                                  fit: BoxFit.contain,
                                  width: double.infinity,
                                ),
                              ),
                              Positioned(
                                bottom: 24.h,
                                child: _buildDotsIndicator(),
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: 32.h),
                        
                        // Title & Subtitle
                        SizedBox(
                          height: 140.h, // Fixed height to prevent layout shifting
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              transitionBuilder: (child, animation) => FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                              child: Column(
                                key: ValueKey<int>(_currentIndex),
                                children: [
                                  Text(
                                    _contents[_currentIndex].title,
                                    textAlign: TextAlign.center,
                                    style: TextStyleManager.heading2.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.black,
                                    ),
                                  ),
                                  SizedBox(height: 16.h),
                                  Text(
                                    _contents[_currentIndex].subtitle,
                                    textAlign: TextAlign.center,
                                    style: TextStyleManager.style14Medium.copyWith(
                                      color: AppColors.textSecondary,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Progress Button
              Padding(
                padding: EdgeInsets.only(bottom: 40.h, top: 20.h),
                child: _buildProgressButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDotsIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _contents.length,
        (index) => Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          height: 8.h,
          width: 8.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentIndex == index
                ? AppColors.primary
                : AppColors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressButton() {
    final bool isLastPage = _currentIndex == _contents.length - 1;
    final double progress = (_currentIndex + 1) / _contents.length;

    return GestureDetector(
      onTap: _nextPage,
      child: SizedBox(
        width: 80.w,
        height: 80.w,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Circular Progress Background
            SizedBox(
              width: 80.w,
              height: 80.w,
              child: CircularProgressIndicator(
                value: 1.0,
                strokeWidth: 4.w,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
            ),
            // Actual Circular Progress
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: progress),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return SizedBox(
                  width: 80.w,
                  height: 80.w,
                  child: CircularProgressIndicator(
                    value: value,
                    strokeWidth: 4.w,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                );
              },
            ),
            // Inner Button
            Container(
              width: 60.w,
              height: 60.w,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: animation, child: child),
                ),
                child: Icon(
                  isLastPage
                      ? Icons.check
                      : (Directionality.of(context) == ui.TextDirection.rtl
                          ? Icons.keyboard_double_arrow_left_rounded
                          : Icons.keyboard_double_arrow_right_rounded),
                  key: ValueKey<bool>(isLastPage),
                  color: AppColors.white,
                  size: 32.w,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
