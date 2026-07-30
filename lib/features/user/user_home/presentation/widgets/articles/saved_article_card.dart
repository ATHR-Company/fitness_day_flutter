import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_shadows.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:fitness_day/features/user/user_home/domain/entities/article_data.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Saved Article Card (horizontal card with image + text + bookmark)
// ─────────────────────────────────────────────────────────────────────────────
class SavedArticleCard extends StatelessWidget {
  final ArticleData article;
  final VoidCallback? onTap;
  final VoidCallback? onBookmarkTap;
  final bool isLoading;

  const SavedArticleCard({
    super.key,
    required this.article,
    this.onTap,
    this.onBookmarkTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.divider, width: 0.5),
          boxShadow: AppShadows.primaryShadow,
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: AppImage(
                article.imageUrl,
                width: 80.w,
                height: 70.h,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 12.w),

            // Title + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: TextStyleManager.style11Medium.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    article.body,
                    style: TextStyleManager.style9Medium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),

            // Bookmark icon
            GestureDetector(
              onTap: onBookmarkTap,
              child: isLoading
                  ? SizedBox(
                      width: 22.sp,
                      height: 22.sp,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : Icon(
                      article.isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                      color: AppColors.primary,
                      size: 22.sp,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
