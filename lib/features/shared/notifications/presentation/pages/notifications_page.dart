import 'package:flutter/material.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

import '../../../../../core/constant/app_assets.dart';
import 'package:fitness_day/core/widgets/app_drawer.dart';
import 'package:fitness_day/core/widgets/app_header.dart';
import 'package:fitness_day/core/widgets/errors/app_error_view.dart';
import 'package:fitness_day/core/errors/app_error.dart';

/// View-model for a single notification card, used when [NotificationsPage]
/// is fed real data (see [NotificationsPage.items]).
class NotificationItem {
  final String title;
  final String subtitle;
  final String time;
  final bool isRead;
  final String? image;
  final VoidCallback? onToggleRead;

  const NotificationItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.isRead,
    this.image,
    this.onToggleRead,
  });
}

class NotificationsPage extends StatelessWidget {
  final bool isEmpty;

  /// Real notification data. When null, the page falls back to its legacy
  /// static/dummy content (used by roles with no backend integration yet).
  final List<NotificationItem>? items;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;

  /// Typed failure, so a connection problem gets the offline view and a
  /// backend refusal shows its own message. Callers that still pass only
  /// [errorMessage] keep the server-error look.
  final AppError? error;
  final VoidCallback? onRetry;
  final Future<void> Function()? onRefresh;
  final ScrollController? scrollController;

  /// The role-appropriate end drawer. Defaults to the specialist [AppDrawer]
  /// for backward compatibility — callers for the user role MUST pass
  /// `UserAppDrawer()` here, since its routes differ from the specialist's.
  final Widget drawer;

  const NotificationsPage({
    super.key,
    this.isEmpty = false, // Set to true to see the empty state
    this.items,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.error,
    this.onRetry,
    this.onRefresh,
    this.scrollController,
    this.drawer = const AppDrawer(),
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: drawer,
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

                  Expanded(child: _buildBody()),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorMessage != null) {
      return AppErrorView(error: error, message: errorMessage, onRetry: onRetry);
    }
    if (items != null) {
      return items!.isEmpty ? _buildEmptyState() : _buildDynamicState(items!);
    }
    return isEmpty ? _buildEmptyState() : _buildPopulatedState();
  }

  Widget _buildDynamicState(List<NotificationItem> items) {
    final unread = items.where((n) => !n.isRead).toList();
    final read = items.where((n) => n.isRead).toList();

    return RefreshIndicator(
      onRefresh: onRefresh ?? () async {},
      child: ListView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        children: [
          if (unread.isNotEmpty) ...[
            Text(
              'notifications.new_notifications'.tr(),
              style: TextStyleManager.heading2.copyWith(
                color: AppColors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            for (final item in unread) ...[
              _buildNotificationCard(
                title: item.title,
                subtitle: item.subtitle,
                time: item.time,
                isRead: item.isRead,
                image: item.image,
                onToggleRead: item.onToggleRead,
              ),
              SizedBox(height: 12.h),
            ],
            SizedBox(height: 16.h),
          ],
          if (read.isNotEmpty) ...[
            Text(
              'notifications.previous_notifications'.tr(),
              style: TextStyleManager.heading2.copyWith(
                color: AppColors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            for (final item in read) ...[
              _buildNotificationCard(
                title: item.title,
                subtitle: item.subtitle,
                time: item.time,
                isRead: item.isRead,
                image: item.image,
                onToggleRead: item.onToggleRead,
              ),
              SizedBox(height: 12.h),
            ],
          ],
          if (isLoadingMore)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: const Center(child: CircularProgressIndicator()),
            ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppImage(SvgIcons.noNotifications, width: 100.w,),
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
    String? image,
    VoidCallback? onToggleRead,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isRead
            ? AppColors.white
            : const Color(0xFFEAF7EC), // light green tint for unread
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
          (image != null && image.isNotEmpty)
              ? AppImage(image, height: 50.sp, width: 20.sp)
              : Icon(
                  Icons.notifications_active,
                  color: AppColors.primary,
                  size: 50.sp,
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

          // Read / Unread icon (Left side in RTL)
          Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: GestureDetector(
              onTap: onToggleRead,
              child: AppImage(
                isRead ? SvgIcons.read : SvgIcons.unread,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
