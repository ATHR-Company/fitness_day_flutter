part of 'articles_list_cubit.dart';

enum ArticlesListStatus { initial, loading, loadingMore, loaded, error }

class ArticlesListState extends Equatable {
  final ArticlesListStatus status;
  final List<ArticleData> articles;
  final bool hasMore;
  final String? errorMessage;

  const ArticlesListState({
    this.status = ArticlesListStatus.initial,
    this.articles = const [],
    this.hasMore = true,
    this.errorMessage,
  });

  ArticlesListState copyWith({
    ArticlesListStatus? status,
    List<ArticleData>? articles,
    bool? hasMore,
    String? errorMessage,
  }) {
    return ArticlesListState(
      status: status ?? this.status,
      articles: articles ?? this.articles,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, articles, hasMore, errorMessage];
}
