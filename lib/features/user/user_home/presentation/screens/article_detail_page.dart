import 'dart:ui' as ui;

import 'package:fitness_day/features/user/user_home/domain/entities/article_data.dart';
import 'package:fitness_day/features/user/user_home/domain/usecases/user_home_usecases.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_shadows.dart';
import '../../../../../core/theme/app_text_styles.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/articles_section.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/generated/locale_keys.g.dart';
import 'package:video_player/video_player.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/core/widgets/app_image.dart';

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
  bool isLoadingSave = false;
  bool isLoadingDetail = true;

  @override
  void initState() {
    super.initState();
    isSaved = widget.article.isSaved;
    _fetchArticleDetail();
  }

  Future<void> _fetchArticleDetail() async {
    final useCase = getIt<GetArticleByIdUseCase>();
    final result = await useCase(widget.article.id);
    if (mounted) {
      setState(() {
        isLoadingDetail = false;
        if (result is Success<ArticleData>) {
          isSaved = result.data.isSaved;
        }
      });
    }
  }

  Future<void> _toggleSave() async {
    if (isLoadingSave) return;
    setState(() => isLoadingSave = true);

    final useCase = getIt<ToggleSaveArticleUseCase>();
    final result = await useCase(widget.article.id);

    setState(() {
      isLoadingSave = false;
      if (result is Success<bool>) {
        isSaved = result.data;
      } else {
        // Optionally show error toast
      }
    });
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

    return _MediaCarousel(
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
                '${widget.article.views}',
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
          return _RelatedArticleCard(
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

// ─────────────────────────────────────────────────────────────────────────────
// Related Article Card (small horizontal card)
// ─────────────────────────────────────────────────────────────────────────────
class _RelatedArticleCard extends StatefulWidget {
  final ArticleData article;
  final VoidCallback? onTap;

  const _RelatedArticleCard({required this.article, this.onTap});

  @override
  State<_RelatedArticleCard> createState() => _RelatedArticleCardState();
}

class _RelatedArticleCardState extends State<_RelatedArticleCard> {
  late bool _isSaved;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isSaved = widget.article.isSaved;
  }

  Future<void> _toggleSave() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final useCase = getIt<ToggleSaveArticleUseCase>();
    final result = await useCase(widget.article.id);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result is Success<bool>) {
          _isSaved = result.data;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
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
            GestureDetector(
              onTap: _toggleSave,
              child: _isLoading
                  ? SizedBox(
                      width: 24.sp,
                      height: 24.sp,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : Icon(
                      _isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: AppColors.primary,
                      size: 24.sp,
                    ),
            ),
            SizedBox(width: 10.w),
            // Title
            Expanded(
              child: Text(
                widget.article.title,
                style: TextStyleManager.style11Medium.copyWith(
                  color: AppColors.black,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
              ),
            ),
            SizedBox(width: 12.w),
            // Image on the left (leading in RTL = right side visually)
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: AppImage(
                widget.article.imageUrl,
                width: 72.w,
                height: 72.w,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Media Carousel — horizontal banner with dot indicators
// ─────────────────────────────────────────────────────────────────────────────
class _MediaCarousel extends StatefulWidget {
  final List<ArticleMediaItem> items;
  final String fallbackImageUrl;
  final String title;

  const _MediaCarousel({
    required this.items,
    required this.fallbackImageUrl,
    required this.title,
  });

  @override
  State<_MediaCarousel> createState() => _MediaCarouselState();
}

class _MediaCarouselState extends State<_MediaCarousel> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openVideoPlayer(BuildContext context, String videoUrl) {
    showDialog(
      context: context,
      barrierColor: AppColors.black.withValues(alpha: 0.8),
      builder: (_) => ArticleVideoDialog(
        videoUrl: videoUrl,
        title: widget.title,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        children: [
          // ── Banner ──────────────────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: SizedBox(
              height: 200.h,
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.items.length,
                onPageChanged: (i) => setState(() => _currentIndex = i),
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  final isVideo = item.isVideo ||
                      item.url.toLowerCase().endsWith('.mp4') ||
                      item.url.toLowerCase().endsWith('.mov');
                  final imageUrl = isVideo ? widget.fallbackImageUrl : item.url;

                  return GestureDetector(
                    onTap: isVideo ? () => _openVideoPlayer(context, item.url) : null,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Image / video thumbnail
                        AppImage(
                          imageUrl,
                          height: 200.h,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        // Play button overlay — only for videos
                        if (isVideo)
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
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // ── Dot indicators ──────────────────────────────────────────────
          if (widget.items.length > 1) ...[
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.items.length, (index) {
                final isActive = index == _currentIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: EdgeInsets.symmetric(horizontal: 3.w),
                  width: isActive ? 20.w : 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : AppColors.divider,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Article Video Player Dialog
// ─────────────────────────────────────────────────────────────────────────────
class ArticleVideoDialog extends StatefulWidget {
  final String videoUrl;
  final String title;

  const ArticleVideoDialog({
    super.key,
    required this.videoUrl,
    required this.title,
  });

  @override
  State<ArticleVideoDialog> createState() => _ArticleVideoDialogState();
}

class _ArticleVideoDialogState extends State<ArticleVideoDialog> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          _controller.play();
        }
      }).catchError((_) {
        if (mounted) {
          setState(() {
            _hasError = true;
          });
        }
      });

    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.black,
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyleManager.style13Medium.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: AppColors.white, size: 22.sp),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Player Area
            Container(
              color: AppColors.black,
              constraints: BoxConstraints(maxHeight: 380.h),
              child: _hasError
                  ? SizedBox(
                      height: 200.h,
                      child: Center(
                        child: Text(
                          'خطأ في تحميل الفيديو',
                          style: TextStyleManager.style12Regular.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    )
                  : !_isInitialized
                      ? SizedBox(
                          height: 200.h,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      : AspectRatio(
                          aspectRatio: _controller.value.aspectRatio > 0
                              ? _controller.value.aspectRatio
                              : 16 / 9,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              VideoPlayer(_controller),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (_controller.value.isPlaying) {
                                      _controller.pause();
                                    } else {
                                      _controller.play();
                                    }
                                  });
                                },
                                child: Container(
                                  color: Colors.transparent,
                                  child: Center(
                                    child: AnimatedOpacity(
                                      opacity: _controller.value.isPlaying ? 0.0 : 1.0,
                                      duration: const Duration(milliseconds: 200),
                                      child: Container(
                                        padding: EdgeInsets.all(16.r),
                                        decoration: BoxDecoration(
                                          color: AppColors.black.withValues(alpha: 0.6),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          _controller.value.isPlaying
                                              ? Icons.pause
                                              : Icons.play_arrow,
                                          color: AppColors.white,
                                          size: 36.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
            ),
            // Progress & Controls
            if (_isInitialized && !_hasError) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Column(
                  children: [
                    VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                        playedColor: AppColors.primary,
                        bufferedColor: Colors.white24,
                        backgroundColor: Colors.white12,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_formatDuration(_controller.value.position)} / ${_formatDuration(_controller.value.duration)}',
                          style: TextStyleManager.style10Medium.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _isMuted ? Icons.volume_off : Icons.volume_up,
                            color: AppColors.white,
                            size: 20.sp,
                          ),
                          onPressed: () {
                            setState(() {
                              _isMuted = !_isMuted;
                              _controller.setVolume(_isMuted ? 0.0 : 1.0);
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }
}
