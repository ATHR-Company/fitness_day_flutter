import 'package:fitness_day/features/user/user_home/domain/entities/article_data.dart';

abstract class SavedArticlesState {}

class SavedArticlesLoading extends SavedArticlesState {}

class SavedArticlesLoaded extends SavedArticlesState {
  final List<ArticleData> articles;
  final Set<String> loadingArticleIds;

  SavedArticlesLoaded({
    required this.articles,
    this.loadingArticleIds = const {},
  });

  SavedArticlesLoaded copyWith({
    List<ArticleData>? articles,
    Set<String>? loadingArticleIds,
  }) {
    return SavedArticlesLoaded(
      articles: articles ?? this.articles,
      loadingArticleIds: loadingArticleIds ?? this.loadingArticleIds,
    );
  }
}

class SavedArticlesError extends SavedArticlesState {
  final String message;
  SavedArticlesError(this.message);
}
