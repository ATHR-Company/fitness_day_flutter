import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_shadows.dart';
import '../../../../../core/theme/app_text_styles.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/articles_section.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/generated/locale_keys.g.dart';

class ArticleDetailPage extends StatelessWidget {
  final ArticleData article;
  final List<ArticleData> relatedArticles;

  const ArticleDetailPage({
    super.key,
    required this.article,
    this.relatedArticles = const [],
  });

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
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                // ── Custom App Bar ──────────────────────────────────────────
                SliverToBoxAdapter(child: _buildHeader(context)),

                // ── Article Image / Video Thumbnail ─────────────────────────
                SliverToBoxAdapter(child: _buildMediaSection()),

                // ── Meta Info (views + date) ────────────────────────────────
                SliverToBoxAdapter(child: _buildMetaInfo()),

                // ── Title ───────────────────────────────────────────────────
                SliverToBoxAdapter(child: _buildTitle()),

                // ── Body Content ────────────────────────────────────────────
                SliverToBoxAdapter(child: _buildBodyContent()),

                // ── Related Articles ────────────────────────────────────────
                if (relatedArticles.isNotEmpty) ...[
                  SliverToBoxAdapter(child: _buildRelatedArticlesHeader()),
                  SliverToBoxAdapter(child: _buildRelatedArticlesList(context)),
                ],

                // Bottom padding
                SliverToBoxAdapter(child: SizedBox(height: 32.h)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Header with back button and title
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          // Title centered
          const Spacer(),
          Text(
            LocaleKeys.home_article_detail_title.tr(),
            style: TextStyleManager.heading2.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          // Back button (right side in RTL)
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_forward_ios,
              size: 20.sp,
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Media section (image with play button overlay for video feel)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildMediaSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.network(
              article.imageUrl,
              height: 200.h,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 200.h,
                color: AppColors.backgroundTint,
                child: Icon(
                  Icons.image_outlined,
                  color: AppColors.greenMint,
                  size: 50.sp,
                ),
              ),
            ),
            // Play button overlay
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.85),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                color: AppColors.primary,
                size: 32.sp,
              ),
            ),
            // Author avatar (top left)
        
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Meta info (views + date)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildMetaInfo() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_month_outlined,
                size: 14.sp,
                color: AppColors.textSecondary,
              ),
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
              Icon(
                Icons.remove_red_eye_outlined,
                size: 14.sp,
                color: AppColors.primary,
              ),
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
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Title
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildTitle() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Text(
        article.title,
        style: TextStyleManager.text2.copyWith(
          color: AppColors.black,
          fontSize: 13.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Body content
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildBodyContent() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Text(
        article.body,
        style: TextStyleManager.style10Medium.copyWith(
          color: AppColors.textSecondary,
          height: 1.8,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Related articles header
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildRelatedArticlesHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Text(
        LocaleKeys.home_related_articles.tr(),
        style: TextStyleManager.heading3.copyWith(
          color: AppColors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Related articles list (horizontal cards)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildRelatedArticlesList(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: List.generate(relatedArticles.length, (index) {
          return _RelatedArticleCard(
            article: relatedArticles[index],
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => ArticleDetailPage(
                    article: relatedArticles[index],
                    relatedArticles:
                        relatedArticles
                            .where((a) => a != relatedArticles[index])
                            .toList()
                          ..add(article),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Related Article Card (small horizontal card)
// ─────────────────────────────────────────────────────────────────────────────
class _RelatedArticleCard extends StatelessWidget {
  final ArticleData article;
  final VoidCallback? onTap;

  const _RelatedArticleCard({required this.article, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.divider, width: 0.5),
          boxShadow: AppShadows.primaryShadow,
        ),
        child: Row(
          children: [
            // Bookmark icon
            Icon(
              Icons.bookmark_outline_rounded,
              color: AppColors.primary,
              size: 24.sp,
            ),
            SizedBox(width: 10.w),
            // Title
            Expanded(
              child: Text(
                article.title,
                style: TextStyleManager.style11Medium.copyWith(
                  color: AppColors.black,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
              ),
            ),
            SizedBox(width: 12.w),
            // Image on the left (leading in RTL = right side visually)
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.network(
                article.imageUrl,
                width: 72.w,
                height: 72.w,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 72.w,
                  height: 72.w,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundTint,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.image_outlined,
                    color: AppColors.greenMint,
                    size: 24.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
