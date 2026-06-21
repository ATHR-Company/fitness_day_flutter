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
      padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 30.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar
          Container(
            width: 50.w,
            height: 50.h,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 5.r,
                  offset: const Offset(0, 2),
                ),
              ],
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.white, width: 1),
              image: const DecorationImage(
                image: NetworkImage(
                  'https://img.magnific.com/free-photo/young-bearded-man-with-striped-shirt_273609-5677.jpg?semt=ais_hybrid&w=740&q=80',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Middle Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "محمد عبدالله",
                style: TextStyleManager.text2.copyWith(
                  color: AppColors.primary,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 18.w,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    "home.specialist_role".tr(),
                    style: TextStyleManager.style10Medium.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Online Toggle Switch + Label
          Column(
            children: [
              const _OnlineToggleSwitch(),
              SizedBox(height: 4.h),
              Text(
                "home.on_duty".tr(),
                style: TextStyleManager.style9Medium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          // Action Buttons (SVG)
          Row(
            children: [
              _buildSvgIconButton(SvgIcons.chatIcon),
              SizedBox(width: 8.w),
              _buildSvgIconButton(SvgIcons.menuIcon),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSvgIconButton(String svgPath) {
    return Container(
      width: 40.w,
      height: 40.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(10.r),
      child: SvgPicture.asset(
        svgPath,
        colorFilter: const ColorFilter.mode(
          AppColors.textSecondary,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}

class _OnlineToggleSwitch extends StatefulWidget {
  const _OnlineToggleSwitch({Key? key}) : super(key: key);

  @override
  State<_OnlineToggleSwitch> createState() => _OnlineToggleSwitchState();
}

class _OnlineToggleSwitchState extends State<_OnlineToggleSwitch> {
  bool isOnline = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isOnline = !isOnline;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: 45.w,
        height: 27.h,
        decoration: BoxDecoration(
          color: isOnline
              ? AppColors.primary
              : AppColors.textSecondary.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20.r),
        ),
        padding: EdgeInsets.all(2.r),
        alignment: isOnline
            ? AlignmentDirectional.centerStart
            : AlignmentDirectional.centerEnd,
        child: Container(
          width: 18.w,
          height: 18.h,
          decoration: const BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
