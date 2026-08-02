import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/core/services/app_event_bus.dart';
import 'package:fitness_day/features/user/user_home/domain/usecases/user_home_usecases.dart';
import 'package:fitness_day/features/user/user_home/domain/entities/article_data.dart';
import 'saved_articles_state.dart';
import 'package:fitness_day/core/errors/app_error.dart';

class SavedArticlesCubit extends Cubit<SavedArticlesState> {
  final GetSavedArticlesUseCase getSavedArticlesUseCase;
  final ToggleSaveArticleUseCase toggleSaveArticleUseCase;

  /// Live patches from the article details screen and the bookmark buttons —
  /// see [AppEventBus].
  late final StreamSubscription<AppEvent> _eventSub;

  SavedArticlesCubit({
    required this.getSavedArticlesUseCase,
    required this.toggleSaveArticleUseCase,
  }) : super(SavedArticlesLoading()) {
    _eventSub = getIt<AppEventBus>().stream.listen(_applyEvent);
  }

  @override
  Future<void> close() {
    _eventSub.cancel();
    return super.close();
  }

  /// [silent] keeps the current list on screen instead of dropping to the
  /// spinner — used when the cubit refetches on its own initiative.
  Future<void> fetchSavedArticles(
      {int page = 1, int limit = 10, bool silent = false}) async {
    if (!silent) emit(SavedArticlesLoading());
    final result = await getSavedArticlesUseCase(page: page, limit: limit);

    if (result is FailureResult) {
      // A silent refetch must not replace a good list with an error screen.
      if (!silent) emit(SavedArticlesError((result as FailureResult).failure.message, error: AppError.from((result as FailureResult).failure)));
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
      // Tell every other screen showing this article that its bookmark is off.
      // Published after the local removal so this cubit's own listener finds
      // nothing left to do.
      getIt<AppEventBus>().publish(
        ArticleChanged(articleId: article.id, isSaved: false),
      );
    } else {
      // Revert loading state if it failed or if it's somehow saved again
      emit(currentState.copyWith(loadingArticleIds: currentLoadingIds));
      if (result is Success<bool>) {
        getIt<AppEventBus>()
            .publish(ArticleChanged(articleId: article.id, isSaved: result.data));
      }
    }
  }

  /// Keeps the saved list in step with bookmarks tapped elsewhere.
  ///
  /// This list is defined by the flag rather than just displaying it, so an
  /// event does not patch a row — it adds or removes one.
  void _applyEvent(AppEvent event) {
    if (event is! ArticleChanged || event.isSaved == null) return;

    final SavedArticlesState current = state;
    if (current is! SavedArticlesLoaded) return;

    final int index =
        current.articles.indexWhere((a) => a.id == event.articleId);

    if (event.isSaved == false) {
      if (index == -1) return;
      emit(SavedArticlesLoaded(
        articles: List<ArticleData>.of(current.articles)..removeAt(index),
        loadingArticleIds: current.loadingArticleIds,
      ));
      return;
    }

    // Saved elsewhere. Already listed → nothing to do beyond the view count.
    if (index != -1) {
      final next = List<ArticleData>.of(current.articles);
      next[index] = next[index].copyWith(views: event.views, isSaved: true);
      emit(SavedArticlesLoaded(
        articles: next,
        loadingArticleIds: current.loadingArticleIds,
      ));
      return;
    }

    // Not listed yet. A row cannot be built from an id alone, and the event
    // deliberately does not carry the whole article — so refetch, silently, so
    // the list does not blank out while it happens.
    fetchSavedArticles(silent: true);
  }
}
