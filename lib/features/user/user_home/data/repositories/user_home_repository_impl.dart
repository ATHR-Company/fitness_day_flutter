import '../../../../../core/network/api_result.dart';
import '../../../../../core/errors/failures.dart';
import '../datasources/user_home_remote_datasource.dart';
import '../../domain/repositories/user_home_repository.dart';
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
  Future<ApiResult<ArticleResponseModel>> getArticles() async {
    try {
      final response = await remoteDataSource.getArticles();
      return Success(response);
    } catch (e) {
      return FailureResult(ServerFailure('Failed to fetch articles'));
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
