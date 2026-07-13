import 'package:fitness_day/features/user/user_home/data/models/article_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fitness_day/features/user/user_home/domain/entities/article_data.dart';
import 'package:fitness_day/features/user/user_home/domain/usecases/user_home_usecases.dart';
import 'package:fitness_day/core/network/api_result.dart';

part 'articles_list_state.dart';

class ArticlesListCubit extends Cubit<ArticlesListState> {
  final GetArticlesUseCase getArticlesUseCase;

  static const int _limit = 2;

  int _currentPage = 1;
  bool _hasMore = true;
  bool _isFetching = false;

  ArticlesListCubit({required this.getArticlesUseCase})
      : super(const ArticlesListState());

  Future<void> loadFirstPage() async {
    if (_isFetching) return;
    _isFetching = true;
    _currentPage = 1;
    _hasMore = true;

    emit(state.copyWith(status: ArticlesListStatus.loading, articles: []));

    final result = await getArticlesUseCase(page: _currentPage, limit: _limit);

    if (result is Success<ArticleResponseModel>) {
      final newArticles = result.data.data
          .map<ArticleData>((a) => a.toEntity())
          .toList();
      _hasMore = newArticles.length >= _limit;
      _currentPage = 2;
      emit(state.copyWith(
        status: ArticlesListStatus.loaded,
        articles: newArticles,
        hasMore: _hasMore,
      ));
    } else if (result is FailureResult) {
      emit(state.copyWith(
        status: ArticlesListStatus.error,
        errorMessage: (result as FailureResult).failure.message,
      ));
    }

    _isFetching = false;
  }

  Future<void> loadNextPage() async {
    if (_isFetching || !_hasMore) return;
    _isFetching = true;

    emit(state.copyWith(status: ArticlesListStatus.loadingMore));

    final result =
        await getArticlesUseCase(page: _currentPage, limit: _limit);

    if (result is Success<ArticleResponseModel>) {
      final newArticles = result.data.data
          .map<ArticleData>((a) => a.toEntity())
          .toList();
      _hasMore = newArticles.length >= _limit;
      _currentPage++;
      emit(state.copyWith(
        status: ArticlesListStatus.loaded,
        articles: [...state.articles, ...newArticles],
        hasMore: _hasMore,
      ));
    } else if (result is FailureResult) {
      // Keep existing articles, just show error snack
      emit(state.copyWith(
        status: ArticlesListStatus.loaded,
        errorMessage: (result as FailureResult).failure.message,
      ));
    }

    _isFetching = false;
  }
}
