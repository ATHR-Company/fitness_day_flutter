import '../../../../../core/network/api_result.dart';
import '../../data/models/user_home_response_model.dart';
import '../../data/models/article_model.dart';

abstract class UserHomeRepository {
  Future<ApiResult<UserHomeResponseModel>> getUserHomeData();
  Future<ApiResult<ArticleResponseModel>> getArticles();
  Future<ApiResult<bool>> toggleSaveArticle(String id);
}
