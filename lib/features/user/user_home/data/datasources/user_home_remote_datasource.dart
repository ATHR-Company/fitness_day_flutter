import '../../../../../core/network/api_service.dart';
import '../models/user_home_response_model.dart';
import '../models/article_model.dart';

abstract class UserHomeRemoteDataSource {
  Future<UserHomeResponseModel> getUserHomeData();
  Future<ArticleResponseModel> getArticles();
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
  Future<ArticleResponseModel> getArticles() async {
    final response = await apiService.get('/articles', queryParameters: {'page': 1, 'limit': 10});
    return ArticleResponseModel.fromJson(response.data);
  }

  @override
  Future<bool> toggleSaveArticle(String id) async {
    final response = await apiService.post('/articles/$id/save');
    return response.data['data'] != null ? response.data['data']['saved'] ?? false : false;
  }
}
