import '../../../../../core/network/api_result.dart';
import '../../../../../core/errors/failures.dart';
import '../datasources/user_home_remote_datasource.dart';
import '../../domain/repositories/user_home_repository.dart';
import '../../domain/entities/article_data.dart';
import '../models/user_home_response_model.dart';
import '../models/article_model.dart';

class UserHomeRepositoryImpl implements UserHomeRepository {
  final UserHomeRemoteDataSource remoteDataSource;

  UserHomeRepositoryImpl(this.remoteDataSource);

  @override
  Future<ApiResult<UserHomeResponseModel>> getUserHomeData() async {
    try {
      final response = await remoteDataSource.getUserHomeData();
      return Success(response);
    } catch (e) {
      return FailureResult(ServerFailure('Failed to fetch home data'));
    }
  }

  @override
  Future<ApiResult<ArticleResponseModel>> getArticles({int page = 1, int limit = 10}) async {
    try {
      final response = await remoteDataSource.getArticles(page: page, limit: limit);
      return Success(response);
    } catch (e) {
      return FailureResult(ServerFailure('Failed to fetch articles'));
    }
  }

  @override
  Future<ApiResult<ArticleData>> getArticleById(String id) async {
    try {
      final model = await remoteDataSource.getArticleById(id);
      return Success(model.toEntity());
    } catch (e) {
      return FailureResult(ServerFailure('Failed to fetch article details'));
    }
  }

  @override
  Future<ApiResult<ArticleResponseModel>> getSavedArticles({int page = 1, int limit = 10}) async {
    try {
      final response = await remoteDataSource.getSavedArticles(page: page, limit: limit);
      return Success(response);
    } catch (e) {
      return FailureResult(ServerFailure('Failed to fetch saved articles'));
    }
  }

  @override
  Future<ApiResult<bool>> toggleSaveArticle(String id) async {
    try {
      final isSaved = await remoteDataSource.toggleSaveArticle(id);
      return Success(isSaved);
    } catch (e) {
      return FailureResult(ServerFailure('Failed to toggle save article'));
    }
  }
}
