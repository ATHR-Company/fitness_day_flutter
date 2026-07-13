import '../../../../../core/network/api_result.dart';
import '../repositories/user_home_repository.dart';
import '../../data/models/user_home_response_model.dart';
import '../../data/models/article_model.dart';
import '../entities/article_data.dart';

class GetUserHomeDataUseCase {
  final UserHomeRepository repository;

  GetUserHomeDataUseCase(this.repository);

  Future<ApiResult<UserHomeResponseModel>> call() {
    return repository.getUserHomeData();
  }
}

class GetArticlesUseCase {
  final UserHomeRepository repository;

  GetArticlesUseCase(this.repository);

  Future<ApiResult<ArticleResponseModel>> call({int page = 1, int limit = 10}) {
    return repository.getArticles(page: page, limit: limit);
  }
}

class GetSavedArticlesUseCase {
  final UserHomeRepository repository;

  GetSavedArticlesUseCase(this.repository);

  Future<ApiResult<ArticleResponseModel>> call({int page = 1, int limit = 10}) {
    return repository.getSavedArticles(page: page, limit: limit);
  }
}

class ToggleSaveArticleUseCase {
  final UserHomeRepository repository;

  ToggleSaveArticleUseCase(this.repository);

  Future<ApiResult<bool>> call(String id) {
    return repository.toggleSaveArticle(id);
  }
}

class GetArticleByIdUseCase {
  final UserHomeRepository repository;

  GetArticleByIdUseCase(this.repository);

  Future<ApiResult<ArticleData>> call(String id) {
    return repository.getArticleById(id);
  }
}
