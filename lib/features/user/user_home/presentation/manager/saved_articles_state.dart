import 'package:fitness_day/features/user/user_home/domain/entities/article_data.dart';
import 'package:fitness_day/core/errors/app_error.dart';

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

  /// Typed form of the failure, so the screen can decide between a
  /// full-screen retry and a message. Null on states not yet migrated.
  final AppError? error;
  SavedArticlesError(this.message, {this.error});
}
