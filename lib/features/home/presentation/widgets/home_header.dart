import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constant/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Action Buttons
          Row(
            children: [
              _buildIconButton(Icons.menu),
              SizedBox(width: 8.w),
              _buildIconButton(Icons.chat_bubble_outline),
            ],
          ),
          
          // Middle Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "محمد عبدالله",
                      style: TextStyleManager.heading2.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    // Online Toggle Switch (Mock)
                    Container(
                      width: 40.w,
                      height: 22.h,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      padding: EdgeInsets.all(2.r),
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 18.w,
                        height: 18.h,
                        decoration: const BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "home.specialist_role".tr(),
                      style: TextStyleManager.style10Medium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.location_on_outlined,
                      size: 14.w,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      "home.on_duty".tr(),
                      style: TextStyleManager.style9Medium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          SizedBox(width: 12.w),
          
          // Avatar
          Container(
            width: 50.w,
            height: 50.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
              image: const DecorationImage(
                image: NetworkImage(
                  'https://ui-avatars.com/api/?name=User&background=random', // Placeholder
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      width: 40.w,
      height: 40.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: AppColors.textSecondary,
        size: 20.w,
      ),
    );
  }
}
