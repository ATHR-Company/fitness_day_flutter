import '../../../../../core/network/api_service.dart';
import '../models/user_home_response_model.dart';
import '../models/article_model.dart';

abstract class UserHomeRemoteDataSource {
  Future<UserHomeResponseModel> getUserHomeData();
  Future<ArticleResponseModel> getArticles({int page = 1, int limit = 10});
  Future<ArticleModel> getArticleById(String id);
  Future<ArticleResponseModel> getSavedArticles({int page = 1, int limit = 10});
  Future<bool> toggleSaveArticle(String id);
}

class UserHomeRemoteDataSourceImpl implements UserHomeRemoteDataSource {
  final ApiService apiService;

  UserHomeRemoteDataSourceImpl(this.apiService);

  @override
  Future<UserHomeResponseModel> getUserHomeData() async {
    final response = await apiService.get('/user-home');
    return UserHomeResponseModel.fromJson(response.data);
  }

  @override
  Future<ArticleResponseModel> getArticles({int page = 1, int limit = 10}) async {
    final response = await apiService.get('/articles', queryParameters: {'page': page, 'limit': limit});
    return ArticleResponseModel.fromJson(response.data);
  }

  @override
  Future<ArticleModel> getArticleById(String id) async {
    final response = await apiService.get('/articles/$id');
    return ArticleModel.fromJson(response.data['data']);
  }

  @override
  Future<ArticleResponseModel> getSavedArticles({int page = 1, int limit = 10}) async {
    final response = await apiService.get('/articles/saved', queryParameters: {'page': page, 'limit': limit});
    return ArticleResponseModel.fromJson(response.data);
  }

  @override
  Future<bool> toggleSaveArticle(String id) async {
    final response = await apiService.post('/articles/$id/save');
    return response.data['data'] != null ? response.data['data']['saved'] ?? false : false;
  }
}
