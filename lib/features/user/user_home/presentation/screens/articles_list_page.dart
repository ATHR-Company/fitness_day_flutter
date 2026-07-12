import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_shadows.dart';
import '../../../../../core/theme/app_text_styles.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/articles_section.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/generated/locale_keys.g.dart';
import 'article_detail_page.dart';
import 'saved_articles_page.dart';

class ArticlesListPage extends StatelessWidget {
  final List<ArticleData> articles;

  const ArticlesListPage({super.key, required this.articles});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
          gradient: AppColors.visitsBackgroundGradient,
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: _buildAppBar(context),
          body: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            itemCount: articles.length,
            itemBuilder: (context, index) => _ArticleListCard(
              article: articles[index],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ArticleDetailPage(
                      article: articles[index],
                      relatedArticles: articles
                          .where((a) => a != articles[index])
                          .toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Text(
        LocaleKeys.home_articles_page_title.tr(),
        style: TextStyleManager.heading2.copyWith(
          color: AppColors.black,
          fontWeight: FontWeight.w700,
        ),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: AppColors.black,
          size: 20.sp,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.bookmark_rounded,
            color: AppColors.black,
            size: 24.sp,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SavedArticlesPage(articles: articles),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Article List Card (Vertical full-width card)
// ─────────────────────────────────────────────────────────────────────────────
class _ArticleListCard extends StatelessWidget {
  final ArticleData article;
  final VoidCallback? onTap;

  const _ArticleListCard({required this.article, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.divider, width: 0.5),
          boxShadow: AppShadows.primaryShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image with bookmark ──────────────────────────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.r),
                    topRight: Radius.circular(16.r),
                  ),
                  child: Image.network(
                    article.imageUrl,
                    height: 180.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 180.h,
                      color: AppColors.backgroundTint,
                      child: Icon(Icons.image_outlined,
                          color: AppColors.greenMint, size: 40.sp),
                    ),
                  ),
                ),
                // Bookmark icon
                Positioned(
                  top: 12.h,
                  left: 12.w,
                  child: Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                      boxShadow: AppShadows.primaryShadow,
                    ),
                    child: Icon(
                      Icons.bookmark_outline_sharp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      size: 22.sp,
                    ),
                  ),
                ),
              ],
            ),

            // ── Content ─────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  SizedBox(height: 10.h),

                  // Title
                  Text(
                    article.title,
                    style: TextStyleManager.heading3.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 8.h),

                  // Body preview
                  Text(
                    article.body,
                    style: TextStyleManager.style11Medium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
