import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_shadows.dart';
import '../../../../../core/theme/app_text_styles.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/articles_section.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/generated/locale_keys.g.dart';
import 'article_detail_page.dart';

import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/features/user/user_home/domain/usecases/user_home_usecases.dart';
import 'package:fitness_day/core/network/api_result.dart';

class SavedArticlesPage extends StatefulWidget {
  final List<ArticleData> articles;

  const SavedArticlesPage({super.key, required this.articles});

  @override
  State<SavedArticlesPage> createState() => _SavedArticlesPageState();
}

class _SavedArticlesPageState extends State<SavedArticlesPage> {
  late List<ArticleData> _articles;
  final Set<String> _loadingArticleIds = {};

  @override
  void initState() {
    super.initState();
    _articles = List.from(widget.articles);
  }

  Future<void> _toggleSave(ArticleData article) async {
    if (_loadingArticleIds.contains(article.id)) return;

    setState(() {
      _loadingArticleIds.add(article.id);
    });

    final useCase = getIt<ToggleSaveArticleUseCase>();
    final result = await useCase(article.id);

    setState(() {
      _loadingArticleIds.remove(article.id);
      if (result is Success<bool>) {
        // Update local article's isSaved state or remove it
        // Depending on UX, usually unsaving removes it from this page
        if (!result.data) {
          _articles.removeWhere((a) => a.id == article.id);
        }
      } else {
        // Handle error (optional)
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
          gradient: AppColors.visitsBackgroundGradient,
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: _buildAppBar(context),
          body: _articles.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  itemCount: _articles.length,
                  itemBuilder: (context, index) {
                    final article = _articles[index];
                    return _SavedArticleCard(
                      article: article,
                      isLoading: _loadingArticleIds.contains(article.id),
                      onBookmarkTap: () => _toggleSave(article),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ArticleDetailPage(
                              article: article,
                              relatedArticles: _articles
                                  .where((a) => a != article)
                                  .toList(),
                            ),
                          ),
                        );
                      },
                    );
                  },
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
        LocaleKeys.home_saved_articles_title.tr(),
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
            LocaleKeys.home_no_saved_articles.tr(),
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
  final VoidCallback? onBookmarkTap;
  final bool isLoading;

  const _SavedArticleCard({
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
