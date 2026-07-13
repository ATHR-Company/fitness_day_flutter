import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/user_home/domain/usecases/user_home_usecases.dart';
import 'package:fitness_day/features/user/user_home/domain/entities/article_data.dart';
import 'saved_articles_state.dart';

class SavedArticlesCubit extends Cubit<SavedArticlesState> {
  final GetSavedArticlesUseCase getSavedArticlesUseCase;
  final ToggleSaveArticleUseCase toggleSaveArticleUseCase;

  SavedArticlesCubit({
    required this.getSavedArticlesUseCase,
    required this.toggleSaveArticleUseCase,
  }) : super(SavedArticlesLoading());

  Future<void> fetchSavedArticles({int page = 1, int limit = 10}) async {
    emit(SavedArticlesLoading());
    final result = await getSavedArticlesUseCase(page: page, limit: limit);

    if (result is FailureResult) {
      emit(SavedArticlesError((result as FailureResult).failure.message));
      return;
    }

    final articlesResult = (result as Success).data.data as List;
    final articles = articlesResult.map<ArticleData>((a) => a.toEntity()).toList();
    emit(SavedArticlesLoaded(articles: articles));
  }

  Future<void> toggleSave(ArticleData article) async {
    final currentState = state;
    if (currentState is! SavedArticlesLoaded) return;

    // Add to loading
    final newLoadingIds = Set<String>.from(currentState.loadingArticleIds)..add(article.id);
    emit(currentState.copyWith(loadingArticleIds: newLoadingIds));

    final result = await toggleSaveArticleUseCase(article.id);

    final currentLoadingIds = Set<String>.from(
      (state is SavedArticlesLoaded) ? (state as SavedArticlesLoaded).loadingArticleIds : newLoadingIds
    )..remove(article.id);

    if (result is Success<bool> && !result.data) {
      // Successfully unsaved -> remove from list
      final updatedArticles = currentState.articles.where((a) => a.id != article.id).toList();
      emit(SavedArticlesLoaded(
        articles: updatedArticles,
        loadingArticleIds: currentLoadingIds,
      ));
    } else {
      // Revert loading state if it failed or if it's somehow saved again
      emit(currentState.copyWith(loadingArticleIds: currentLoadingIds));
    }
  }
}
