import '../../../../../core/network/api_result.dart';
import '../repositories/user_home_repository.dart';
import '../../data/models/user_home_response_model.dart';
import '../../data/models/article_model.dart';

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

  Future<ApiResult<ArticleResponseModel>> call() {
    return repository.getArticles();
  }
}

class ToggleSaveArticleUseCase {
  final UserHomeRepository repository;

  ToggleSaveArticleUseCase(this.repository);

  Future<ApiResult<bool>> call(String id) {
    return repository.toggleSaveArticle(id);
  }
}
