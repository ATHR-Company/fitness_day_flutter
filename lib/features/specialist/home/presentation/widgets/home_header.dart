import 'package:flutter/material.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/constant/app_assets.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../shared/conversations/presentation/pages/conversations_page.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/routes/specialist_routes/app_routes.dart';

class HomeHeader extends StatelessWidget {
  final String name;
  final String branch;
  final String avatarUrl;

  const HomeHeader({
    super.key,
    required this.name,
    required this.branch,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.headerBackground,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        children: [
          // Avatar
          GestureDetector(
            onTap: () {
              context.push(SpecialistAppRoutes.profile);
            },
            child: Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.greenSoftTint, width: 2),
                image: DecorationImage(
                  image: NetworkImage(
                    avatarUrl.isNotEmpty
                        ? avatarUrl
                        : 'https://img.magnific.com/free-photo/young-bearded-man-with-striped-shirt_273609-5677.jpg?semt=ais_hybrid&w=740&q=80',
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
                  name,
                  style: TextStyleManager.style14Bold.copyWith(
                    color: AppColors.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14.w,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 4.w),
                    Flexible(
                      child: Text(
                        branch,
                        style: TextStyleManager.style11Medium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
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
        child: AppImage(
          svgPath,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
