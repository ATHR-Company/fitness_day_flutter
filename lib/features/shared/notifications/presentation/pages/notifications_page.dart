import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../core/constant/app_assets.dart';
import 'package:fitness_day/core/widgets/app_drawer.dart';
import 'package:fitness_day/core/widgets/app_header.dart';

class NotificationsPage extends StatelessWidget {
  final bool isEmpty;

  const NotificationsPage({
    super.key,
    this.isEmpty = false, // Set to true to see the empty state
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const AppDrawer(),
      body: Builder(
        builder: (context) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppColors.visitsBackgroundGradient,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  SizedBox(height: 20.h),

                  // Custom Header
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: AppHeader(
                      title: 'notifications.title'.tr(),
                      onMenuPressed: () {
                        Scaffold.of(context).openEndDrawer();
                      },
                    ),
                  ),

                  SizedBox(height: 32.h),

                  Expanded(
                    child: isEmpty
                        ? _buildEmptyState()
                        : _buildPopulatedState(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(SvgIcons.notification),
          SizedBox(height: 32.h),
          Text(
            'notifications.empty_title'.tr(),
            textAlign: TextAlign.center,
            style: TextStyleManager.heading2.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'notifications.empty_subtitle'.tr(),
            textAlign: TextAlign.center,
            style: TextStyleManager.heading3.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          SizedBox(height: 60.h), // Push slightly up
        ],
      ),
    );
  }

  Widget _buildPopulatedState() {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      children: [
        // New Notifications Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'notifications.new_notifications'.tr(),
              style: TextStyleManager.heading2.copyWith(
                color: AppColors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'notifications.mark_as_read'.tr(),
              style: TextStyleManager.heading3.copyWith(
                color: AppColors.primary,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),

        _buildNotificationCard(
          title: 'notifications.dummy_title_1'.tr(),
          subtitle: 'notifications.dummy_subtitle_1'.tr(),
          time: '''09:00 ${'shared_mock_pm'.tr()}''',
          isRead: false,
        ),

        SizedBox(height: 32.h),

        // Previous Notifications Section
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'notifications.previous_notifications'.tr(),
              style: TextStyleManager.heading2.copyWith(
                color: AppColors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),

        _buildNotificationCard(
          title: 'notifications.dummy_title_2'.tr(),
          subtitle: 'notifications.dummy_subtitle_2'.tr(),
          time: '''09:00 ${'shared_mock_pm'.tr()}''',
          isRead: true,
        ),
        SizedBox(height: 12.h),
        _buildNotificationCard(
          title: 'notifications.dummy_title_1'.tr(),
          subtitle: 'notifications.dummy_subtitle_1'.tr(),
          time: '''09:00 ${'shared_mock_pm'.tr()}''',
          isRead: true,
        ),
        SizedBox(height: 12.h),
        _buildNotificationCard(
          title: 'notifications.dummy_title_1'.tr(),
          subtitle: 'notifications.dummy_subtitle_1'.tr(),
          time: '''09:00 ${'shared_mock_pm'.tr()}''',
          isRead: true,
        ),
        SizedBox(height: 12.h),
        _buildNotificationCard(
          title: 'notifications.dummy_title_1'.tr(),
          subtitle: 'notifications.dummy_subtitle_1'.tr(),
          time: '''09:00 ${'shared_mock_pm'.tr()}''',
          isRead: true,
        ),
        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildNotificationCard({
    required String title,
    required String subtitle,
    required String time,
    required bool isRead,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isRead
              ? AppColors.divider.withValues(alpha: 0.5)
              : AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bell Icon (Right side in RTL)
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: AppColors.divider.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.notifications_active,
              color: AppColors.primary,
              size: 20.sp,
            ),
          ),

          SizedBox(width: 12.w),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyleManager.heading3.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyleManager.heading3.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      time,
                      style: TextStyleManager.heading3.copyWith(
                        color: AppColors.textSecondary.withValues(alpha: 0.7),
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(width: 12.w),

          // Checkmark (Left side in RTL)
          Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: SvgPicture.asset(SvgIcons.read),
          ),
        ],
      ),
    );
  }
}
