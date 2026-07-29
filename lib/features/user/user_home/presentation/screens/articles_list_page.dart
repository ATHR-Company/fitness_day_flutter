import 'package:fitness_day/features/user/user_home/presentation/screens/article_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/generated/locale_keys.g.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_shadows.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/user/user_home/domain/usecases/user_home_usecases.dart';
import 'package:fitness_day/features/user/user_home/presentation/manager/articles_list_cubit.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/articles_section.dart';
import 'saved_articles_page.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:fitness_day/core/widgets/app_snack_bar.dart';

class ArticlesListPage extends StatelessWidget {
  /// الـ articles دي بتتجاهل — الـ page دلوقتي بتجيب data من API مباشرة.
  /// بس محتفظين بالـ parameter عشان مش نكسر الـ call الموجود في home_page.
  final List<ArticleData> articles;

  const ArticlesListPage({super.key, required this.articles});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ArticlesListCubit>()..loadFirstPage(),
      child: const _ArticlesListContent(),
    );
  }
}

class _ArticlesListContent extends StatefulWidget {
  const _ArticlesListContent();

  @override
  State<_ArticlesListContent> createState() => _ArticlesListContentState();
}

class _ArticlesListContentState extends State<_ArticlesListContent> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ArticlesListCubit>().loadNextPage();
    }
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
        body: BlocConsumer<ArticlesListCubit, ArticlesListState>(
          listener: (context, state) {
            if (state.status == ArticlesListStatus.loaded &&
                state.errorMessage != null) {
              showAppSnackBar(context, text: state.errorMessage!, isError: true);
            }
          },
          builder: (context, state) {
            // Full-screen loading (first page)
            if (state.status == ArticlesListStatus.loading) {
              return Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            // Full-screen error
            if (state.status == ArticlesListStatus.error) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline,
                        color: AppColors.primary, size: 48.sp),
                    SizedBox(height: 12.h),
                    Text(
                      state.errorMessage ?? 'حدث خطأ ما',
                      style: TextStyleManager.style11Medium,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<ArticlesListCubit>().loadFirstPage(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                      ),
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            }

            final articles = state.articles;

            return ListView.builder(
              controller: _scrollController,
              padding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              // +1 for the loading indicator at the bottom
              itemCount: articles.length + (state.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == articles.length) {
                  // Bottom loading indicator while fetching next page
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary),
                    ),
                  );
                }

                return _ArticleListCard(
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
                    ).then((_) {
                      if (context.mounted) {
                        context.read<ArticlesListCubit>().loadFirstPage();
                      }
                    });
                  },
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
        LocaleKeys.home_articles_page_title.tr(),
        style: TextStyleManager.heading2.copyWith(
          color: AppColors.black,
          fontWeight: FontWeight.w700,
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: AppColors.black, size: 20.sp),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.bookmark_rounded,
              color: AppColors.black, size: 24.sp),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SavedArticlesPage(),
              ),
            ).then((_) {
              if (context.mounted) {
                context.read<ArticlesListCubit>().loadFirstPage();
              }
            });
          },
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Article List Card
// ─────────────────────────────────────────────────────────────────────────────
class _ArticleListCard extends StatefulWidget {
  final ArticleData article;
  final VoidCallback? onTap;

  const _ArticleListCard({required this.article, this.onTap});

  @override
  State<_ArticleListCard> createState() => _ArticleListCardState();
}

class _ArticleListCardState extends State<_ArticleListCard> {
  late bool _isSaved;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isSaved = widget.article.isSaved;
  }

  Future<void> _toggleSave() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

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
            // ── Image with bookmark ──────────────────────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.r),
                    topRight: Radius.circular(16.r),
                  ),
                  child: AppImage(
                    widget.article.imageUrl,
                    height: 180.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 12.h,
                  left: 12.w,
                  child: GestureDetector(
                    onTap: _toggleSave,
                    child: Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                        boxShadow: AppShadows.primaryShadow,
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 22.sp,
                              height: 22.sp,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            )
                          : Icon(
                              _isSaved
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_outline_sharp,
                              color: AppColors.primary,
                              size: 22.sp,
                            ),
                    ),
                  ),
                ),
              ],
            ),

            // ── Content ─────────────────────────────────────────────
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
                            widget.article.date,
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
                  SizedBox(height: 10.h),
                  Text(
                    widget.article.title,
                    style: TextStyleManager.heading3.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    widget.article.body,
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
