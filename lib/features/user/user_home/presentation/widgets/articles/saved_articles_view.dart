import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/generated/locale_keys.g.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/user/user_home/presentation/manager/saved_articles_cubit.dart';
import 'package:fitness_day/features/user/user_home/presentation/manager/saved_articles_state.dart';
import 'package:fitness_day/features/user/user_home/presentation/screens/article_detail_page.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/articles/saved_article_card.dart';
import 'package:fitness_day/core/widgets/errors/app_error_view.dart';

class SavedArticlesView extends StatelessWidget {
  const SavedArticlesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.visitsBackgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(context),
        body: BlocBuilder<SavedArticlesCubit, SavedArticlesState>(
          builder: (context, state) {
            if (state is SavedArticlesLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SavedArticlesError) {
              return AppErrorView(
                error: state.error,
                message: state.message,
                onRetry: () =>
                    context.read<SavedArticlesCubit>().fetchSavedArticles(),
              );
            } else if (state is SavedArticlesLoaded) {
              final articles = state.articles;
              if (articles.isEmpty) return _buildEmptyState();

              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                itemCount: articles.length,
                itemBuilder: (context, index) {
                  final article = articles[index];
                  return SavedArticleCard(
                    article: article,
                    isLoading: state.loadingArticleIds.contains(article.id),
                    onBookmarkTap: () => context.read<SavedArticlesCubit>().toggleSave(article),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ArticleDetailPage(
                            article: article,
                            relatedArticles: articles
                                .where((a) => a != article)
                                .toList(),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            }
            return const SizedBox.shrink();
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
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: AppColors.black,
          size: 20.sp,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
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
