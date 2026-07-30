import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/generated/locale_keys.g.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_snack_bar.dart';
import 'package:fitness_day/features/user/user_home/presentation/manager/articles_list_cubit.dart';
import 'package:fitness_day/features/user/user_home/presentation/screens/article_detail_page.dart';
import 'package:fitness_day/features/user/user_home/presentation/screens/saved_articles_page.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/articles/article_list_card.dart';

class ArticlesListContent extends StatefulWidget {
  const ArticlesListContent({super.key});

  @override
  State<ArticlesListContent> createState() => _ArticlesListContentState();
}

class _ArticlesListContentState extends State<ArticlesListContent> {
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

                return ArticleListCard(
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
