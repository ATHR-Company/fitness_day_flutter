import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../core/constant/app_assets.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../shared/conversations/presentation/pages/conversations_page.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/routes/app_routes.dart';

class userHomeHeader extends StatelessWidget {
  const userHomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        children: [
          // Avatar
          GestureDetector(
            onTap: () {
              context.push(AppRoutes.profile);
            },
            child: Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.greenSoftTint, width: 2),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://img.magnific.com/free-photo/young-bearded-man-with-striped-shirt_273609-5677.jpg?semt=ais_hybrid&w=740&q=80',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "مرحبا بك !",
                  style: TextStyleManager.style9Medium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "محمد عبدالله",
                  style: TextStyleManager.style14Bold.copyWith(
                    color: AppColors.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          SizedBox(width: 16.w),

          // Chat Button
          _buildSvgIconButton(
            svgPath: SvgIcons.chatIcon,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ConversationsPage(isEmpty: false),
                ),
              );
            },
          ),

          SizedBox(width: 8.w),

          // Menu Button
          _buildSvgIconButton(
            svgPath: SvgIcons.menuIcon,
            onTap: () {
              Scaffold.of(context).openEndDrawer();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSvgIconButton({required String svgPath, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44.w,
        height: 44.w,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        padding: EdgeInsets.all(12.r),
        child: SvgPicture.asset(
          svgPath,
          colorFilter: const ColorFilter.mode(
            AppColors.textSecondary,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}

class _OnlineToggleSwitch extends StatefulWidget {
  const _OnlineToggleSwitch();

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
        width: 44.w,
        height: 24.h,
        decoration: BoxDecoration(
          color: isOnline
              ? AppColors.primary
              : AppColors.textSecondary.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20.r),
        ),
        padding: EdgeInsets.all(2.r),
        alignment: isOnline
            ? AlignmentDirectional.centerStart
            : AlignmentDirectional.centerEnd,
        child: Container(
          width: 20.w,
          height: 20.h,
          decoration: const BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
