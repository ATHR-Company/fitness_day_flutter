import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_shadows.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../widgets/articles_section.dart';
import 'article_detail_page.dart';

class SavedArticlesPage extends StatelessWidget {
  final List<ArticleData> articles;

  const SavedArticlesPage({super.key, required this.articles});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.visitsBackgroundGradient,
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: _buildAppBar(context),
          body: articles.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  itemCount: articles.length,
                  itemBuilder: (context, index) => _SavedArticleCard(
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
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'المقالات المحفوظة',
        style: TextStyleManager.heading2.copyWith(
          color: AppColors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: const SizedBox(),
      actions: [
        IconButton(
          icon: Icon(
            Icons.arrow_forward_ios,
            color: AppColors.black,
            size: 20.sp,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border_rounded,
            size: 64.sp,
            color: AppColors.divider,
          ),
          SizedBox(height: 16.h),
          Text(
            'لا توجد مقالات محفوظة',
            style: TextStyleManager.heading3.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Saved Article Card (horizontal card with image + text + bookmark)
// ─────────────────────────────────────────────────────────────────────────────
class _SavedArticleCard extends StatelessWidget {
  final ArticleData article;
  final VoidCallback? onTap;

  const _SavedArticleCard({required this.article, this.onTap});

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
              child: Image.network(
                article.imageUrl,
                width: 80.w,
                height: 70.h,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 80.w,
                  height: 70.h,
                  color: AppColors.backgroundTint,
                  child: Icon(Icons.image_outlined,
                      color: AppColors.greenMint, size: 24.sp),
                ),
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
            Icon(
              Icons.bookmark_rounded,
              color: AppColors.primary,
              size: 22.sp,
            ),
          ],
        ),
      ),
    );
  }
}
