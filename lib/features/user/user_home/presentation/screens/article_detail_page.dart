import 'dart:ui' as ui;

import 'package:fitness_day/features/user/user_home/domain/entities/article_data.dart';
import 'package:fitness_day/features/user/user_home/domain/usecases/user_home_usecases.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/articles/media_carousel.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/articles/related_article_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/generated/locale_keys.g.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/core/services/app_event_bus.dart';

class ArticleDetailPage extends StatefulWidget {
  final ArticleData article;
  final List<ArticleData> relatedArticles;

  const ArticleDetailPage({
    super.key,
    required this.article,
    this.relatedArticles = const [],
  });

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  late bool isSaved;

  /// The view count the server returned for *this* visit. Reading the article
  /// is what increments it, so the number passed in from the list is already
  /// one behind by the time this screen is built — it was only ever a
  /// placeholder until the fetch lands.
  late int views;

  bool isLoadingSave = false;
  bool isLoadingDetail = true;

  @override
  void initState() {
    super.initState();
    isSaved = widget.article.isSaved;
    views = widget.article.views;
    _fetchArticleDetail();
  }

  Future<void> _fetchArticleDetail() async {
    final useCase = getIt<GetArticleByIdUseCase>();
    final result = await useCase(widget.article.id);
    if (!mounted) return;
    setState(() {
      isLoadingDetail = false;
      if (result is Success<ArticleData>) {
        isSaved = result.data.isSaved;
        views = result.data.views;
      }
    });
    if (result is Success<ArticleData>) {
      // Every list showing this article is now one view behind. This GET is the
      // only place the new count exists, so it is broadcast rather than left
      // for the lists to rediscover with a refetch of their own.
      getIt<AppEventBus>().publish(ArticleChanged(
        articleId: widget.article.id,
        views: result.data.views,
        isSaved: result.data.isSaved,
      ));
    }
  }

  Future<void> _toggleSave() async {
    if (isLoadingSave) return;
    setState(() => isLoadingSave = true);

    final useCase = getIt<ToggleSaveArticleUseCase>();
    final result = await useCase(widget.article.id);
    if (!mounted) return;

    setState(() {
      isLoadingSave = false;
      if (result is Success<bool>) {
        isSaved = result.data;
      } else {
        // Optionally show error toast
      }
    });

    if (result is Success<bool>) {
      // `views` rides along so the saved-articles list can build a full row if
      // this is the first time it hears about the article.
      getIt<AppEventBus>().publish(ArticleChanged(
        articleId: widget.article.id,
        isSaved: result.data,
        views: views,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == ui.TextDirection.rtl;
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.visitsBackgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            LocaleKeys.home_article_detail_title.tr(),
            style: TextStyleManager.heading2.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          automaticallyImplyLeading: false,
          leading: isRtl
              ? IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: AppColors.black, size: 20.sp),
                  onPressed: () => Navigator.of(context).pop(),
                )
              : IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: AppColors.black, size: 20.sp),
                  onPressed: () => Navigator.of(context).pop(),
                ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 12.w, left: 12.w),
              child: GestureDetector(
                onTap: isLoadingDetail ? null : _toggleSave,
                child: (isLoadingSave || isLoadingDetail)
                    ? SizedBox(
                        width: 24.sp,
                        height: 24.sp,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                      )
                    : Icon(
                        isSaved ? Icons.bookmark : Icons.bookmark_border,
                        size: 24.sp,
                        color: AppColors.primary,
                      ),
              ),
            ),
          ],
        ),
        body: CustomScrollView(
          slivers: [
            // ── Article Image / Video Thumbnail ─────────────────────────
            SliverToBoxAdapter(child: _buildMediaSection()),

            // ── Meta Info (views + date) ────────────────────────────────
            SliverToBoxAdapter(child: _buildMetaInfo()),

            // ── Title ───────────────────────────────────────────────────
            SliverToBoxAdapter(child: _buildTitle()),

            // ── Body Content ────────────────────────────────────────────
            SliverToBoxAdapter(child: _buildBodyContent()),

            // ── Related Articles ────────────────────────────────────────
            if (widget.relatedArticles.isNotEmpty) ...[
              SliverToBoxAdapter(child: _buildRelatedArticlesHeader()),
              SliverToBoxAdapter(child: _buildRelatedArticlesList(context)),
            ],

            // Bottom padding
            SliverToBoxAdapter(child: SizedBox(height: 32.h)),
          ],
        ),
      ),
    );
  }



  // ─────────────────────────────────────────────────────────────────────────
  // Media section — horizontal banner carousel with dot indicators
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildMediaSection() {
    // Build media list: prefer article.media, fallback to mainPhoto
    final mediaItems = widget.article.media.isNotEmpty
        ? widget.article.media
        : [ArticleMediaItem(url: widget.article.imageUrl, type: 'PHOTO')];

    if (mediaItems.isEmpty) return const SizedBox.shrink();

    return MediaCarousel(
      items: mediaItems,
      fallbackImageUrl: widget.article.imageUrl,
      title: widget.article.title,
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
                widget.article.date,
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
                '$views',
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
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Text(
        widget.article.title,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.article.details.map((detail) {
          return Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (detail.title.isNotEmpty)
                  Text(
                    detail.title,
                    style: TextStyleManager.style14Bold.copyWith(
                      color: AppColors.black,
                      height: 1.5,
                    ),
                  ),
                if (detail.title.isNotEmpty) SizedBox(height: 8.h),
                Text(
                  detail.description,
                  style: TextStyleManager.style12Regular.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.8,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
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
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        children: List.generate(widget.relatedArticles.length, (index) {
          return RelatedArticleCard(
            article: widget.relatedArticles[index],
            onTap: () {
              // push, not pushReplacement: replacing the page left no back
              // stack, so returning from any related article jumped straight
              // to whatever was below the first one (the home) instead of the
              // previous article.
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ArticleDetailPage(
                    article: widget.relatedArticles[index],
                    relatedArticles:
                        widget.relatedArticles
                            .where((a) => a != widget.relatedArticles[index])
                            .toList()
                          ..add(widget.article),
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
