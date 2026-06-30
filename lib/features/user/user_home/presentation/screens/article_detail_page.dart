import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_shadows.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../widgets/articles_section.dart';

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
              SliverToBoxAdapter(
                child: _buildHeader(context),
              ),

              // ── Article Image / Video Thumbnail ─────────────────────────
              SliverToBoxAdapter(
                child: _buildMediaSection(),
              ),

              // ── Meta Info (views + date) ────────────────────────────────
              SliverToBoxAdapter(
                child: _buildMetaInfo(),
              ),

              // ── Title ───────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: _buildTitle(),
              ),

              // ── Body Content ────────────────────────────────────────────
              SliverToBoxAdapter(
                child: _buildBodyContent(),
              ),

              // ── Related Articles ────────────────────────────────────────
              if (relatedArticles.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: _buildRelatedArticlesHeader(),
                ),
                SliverToBoxAdapter(
                  child: _buildRelatedArticlesList(context),
                ),
              ],

              // Bottom padding
              SliverToBoxAdapter(
                child: SizedBox(height: 32.h),
              ),
            ],
          ),
        ),
      ),
    ));
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
            'تفاصيل المقالة',
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
                child: Icon(Icons.image_outlined,
                    color: AppColors.greenMint, size: 50.sp),
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
            Positioned(
              top: 12.h,
              left: 12.w,
              child: CircleAvatar(
                radius: 18.r,
                backgroundColor: AppColors.primary,
                child: Text(
                  'M',
                  style: TextStyleManager.heading3.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
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
        children: [
          // Views
          Row(
            children: [
              Icon(Icons.remove_red_eye_outlined,
                  size: 16.sp, color: AppColors.primary),
              SizedBox(width: 4.w),
              Text(
                '${article.views}',
                style: TextStyleManager.style11Medium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Date
          Row(
            children: [
              Icon(Icons.calendar_month_outlined,
                  size: 16.sp, color: AppColors.textSecondary),
              SizedBox(width: 4.w),
              Text(
                article.date,
                style: TextStyleManager.style11Medium.copyWith(
                  color: AppColors.textSecondary,
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
        style: TextStyleManager.heading2.copyWith(
          color: AppColors.primary,
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
        style: TextStyleManager.style13Medium.copyWith(
          color: AppColors.textPrimary,
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
        'مقالات قد تعجبك',
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
    return SizedBox(
      height: 110.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(right: 16.w),
        itemCount: relatedArticles.length,
        itemBuilder: (context, index) => _RelatedArticleCard(
          article: relatedArticles[index],
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => ArticleDetailPage(
                  article: relatedArticles[index],
                  relatedArticles: relatedArticles
                      .where((a) => a != relatedArticles[index])
                      .toList()
                    ..add(article),
                ),
              ),
            );
          },
        ),
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
        width: 280.w,
        margin: EdgeInsets.only(left: 12.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.divider, width: 0.5),
          boxShadow: AppShadows.primaryShadow,
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(12.r),
                bottomRight: Radius.circular(12.r),
              ),
              child: Image.network(
                article.imageUrl,
                width: 90.w,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 90.w,
                  color: AppColors.backgroundTint,
                  child: Icon(Icons.image_outlined,
                      color: AppColors.greenMint, size: 24.sp),
                ),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      article.title,
                      style: TextStyleManager.style11Medium.copyWith(
                        color: AppColors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
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
            ),
          ],
        ),
      ),
    );
  }
}
