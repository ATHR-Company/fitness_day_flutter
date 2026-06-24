import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

enum ClientStatus {
  active,
  needsFollowUp,
  expired,
}

class ClientCard extends StatelessWidget {
  final String clientName;
  final String currentWeight;
  final String goal;
  final String lastVisit;
  final ClientStatus status;
  final int? commitmentRate;
  final VoidCallback onViewProfile;

  const ClientCard({
    super.key,
    required this.clientName,
    required this.currentWeight,
    required this.goal,
    required this.lastVisit,
    required this.status,
    this.commitmentRate,
    required this.onViewProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Commitment Badge
          Align(
            alignment: AlignmentDirectional.topEnd, // Top left in RTL
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              decoration: _getBadgeDecoration(status),
              child: Text(
                _getBadgeText(status),
                style: TextStyleManager.style10Medium.copyWith(
                  color: _getBadgeTextColor(status),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    Container(
                      width: 50.r,
                      height: 50.r,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.divider, width: 2),
                      ),
                      child: ClipOval(
                        child: Icon(Icons.person, size: 30.sp, color: Colors.grey),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    // Name & Weight
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            clientName,
                            style: TextStyleManager.style14Medium,
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Text(
                                'clients_page.current_weight'.tr(),
                                style: TextStyleManager.style8Medium.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                ' $currentWeight ${'clients_page.kg'.tr()}',
                                style: TextStyleManager.style9Medium.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                
                // Details and Button Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow('clients_page.client_name'.tr(), clientName, true),
                          SizedBox(height: 6.h),
                          _buildDetailRow('clients_page.goal'.tr(), goal, true),
                          SizedBox(height: 6.h),
                          _buildDetailRow('clients_page.last_visit'.tr(), lastVisit, false),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    // Button
                    ElevatedButton(
                      onPressed: onViewProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'clients_page.view_profile'.tr().replaceAll('»', '').trim(),
                            style: TextStyleManager.style11Medium.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Icon(Icons.keyboard_double_arrow_left, size: 16.sp, color: AppColors.white),
                        ],
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

  Widget _buildDetailRow(String label, String value, bool isValueGreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyleManager.style9Medium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Text(
            value,
            style: TextStyleManager.style9Medium.copyWith(
              color: isValueGreen ? AppColors.primary : AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  BoxDecoration _getBadgeDecoration(ClientStatus status) {
    final borderRadius = BorderRadiusDirectional.only(
      topEnd: Radius.circular(16.r),
      bottomStart: Radius.circular(16.r),
    );

    switch (status) {
      case ClientStatus.active:
        return BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7CD588), Color(0xFFE6FFE9), Color(0xFF7CD588)],
            begin: AlignmentDirectional.centerStart,
            end: AlignmentDirectional.centerEnd,
          ),
          borderRadius: borderRadius,
        );
      case ClientStatus.needsFollowUp:
        return BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE7E000), Color(0xFFFFFFFF), Color(0xFFDCC134)],
            begin: AlignmentDirectional.centerStart,
            end: AlignmentDirectional.centerEnd,
          ),
          borderRadius: borderRadius,
        );
      case ClientStatus.expired:
        return BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD2D2), Color(0xFFFFFFFF), Color(0xFFFFD2D2)],
            begin: AlignmentDirectional.centerStart,
            end: AlignmentDirectional.centerEnd,
          ),
          borderRadius: borderRadius,
        );
    }
  }

  Color _getBadgeTextColor(ClientStatus status) {
    switch (status) {
      case ClientStatus.active:
        return AppColors.greenForest;
      case ClientStatus.needsFollowUp:
        return const Color(0xFFB59A1D); // Darker yellow/brown
      case ClientStatus.expired:
        return AppColors.error;
    }
  }

  String _getBadgeText(ClientStatus status) {
    switch (status) {
      case ClientStatus.active:
      case ClientStatus.needsFollowUp:
        return 'clients_page.commitment_rate'.tr(args: [commitmentRate?.toString() ?? '0']);
      case ClientStatus.expired:
        return 'clients_page.inactive_subscription'.tr();
    }
  }
}
