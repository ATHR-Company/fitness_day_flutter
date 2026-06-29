import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_shadows.dart';
import '../../../../../core/theme/app_text_styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data Model
// ─────────────────────────────────────────────────────────────────────────────
class ArticleData {
  final String imageUrl;
  final String date;
  final int views;
  final String title;
  final String body;

  const ArticleData({
    required this.imageUrl,
    required this.date,
    required this.views,
    required this.title,
    required this.body,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Articles Horizontal List
// ─────────────────────────────────────────────────────────────────────────────
class ArticlesSection extends StatelessWidget {
  final List<ArticleData> articles;

  const ArticlesSection({super.key, required this.articles});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 340.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(left: 16.w),
        itemCount: articles.length,
        itemBuilder: (context, index) =>
            ArticleCard(article: articles[index]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Article Card
// ─────────────────────────────────────────────────────────────────────────────
class ArticleCard extends StatelessWidget {
  final ArticleData article;

  const ArticleCard({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260.w,
      margin: EdgeInsets.only(left: 12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.divider, width: 0.5),
        boxShadow: AppShadows.profileItemShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.r),
              topRight: Radius.circular(16.r),
            ),
            child: Image.network(
              article.imageUrl,
              height: 150.h,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                height: 150.h,
                color: AppColors.backgroundTint,
                child: Icon(Icons.image_outlined,
                    color: AppColors.greenMint, size: 40.sp),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date + Views
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_month_outlined,
                            size: 14.sp, color: AppColors.textSecondary),
                        SizedBox(width: 4.w),
                        Text(
                          article.date,
                          style: TextStyleManager.style10Medium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.remove_red_eye_outlined,
                            size: 14.sp, color: AppColors.primary),
                        SizedBox(width: 4.w),
                        Text(
                          '${article.views}',
                          style: TextStyleManager.style10Medium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 8.h),

                // Title
                Text(
                  article.title,
                  style: TextStyleManager.smallButtons.copyWith(
                    color: AppColors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 11.sp,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: 6.h),

                // Body preview
                Text(
                  article.body,
                  style: TextStyleManager.dataCard.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 9.sp,
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
