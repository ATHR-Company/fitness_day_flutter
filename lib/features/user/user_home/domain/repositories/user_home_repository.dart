import '../../../../../core/network/api_result.dart';
import '../../data/models/user_home_response_model.dart';
import '../../data/models/article_model.dart';
import '../entities/article_data.dart';

abstract class UserHomeRepository {
  Future<ApiResult<UserHomeResponseModel>> getUserHomeData();
  Future<ApiResult<ArticleResponseModel>> getArticles({int page = 1, int limit = 10});
  Future<ApiResult<ArticleData>> getArticleById(String id);
  Future<ApiResult<ArticleResponseModel>> getSavedArticles({int page = 1, int limit = 10});
  Future<ApiResult<bool>> toggleSaveArticle(String id);
}
