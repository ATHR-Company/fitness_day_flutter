import 'package:fitness_day/core/constant/api_endpoints.dart';
import 'package:fitness_day/core/network/api_service.dart';
import 'package:fitness_day/features/specialist/clients/data/models/client_progress_model.dart';

abstract class UserProgressRemoteDataSource {
  Future<ClientProgressResponseModel> getUserProgress({required int visitNumber});
}

class UserProgressRemoteDataSourceImpl implements UserProgressRemoteDataSource {
  final ApiService _apiService;

  UserProgressRemoteDataSourceImpl(this._apiService);

  @override
  Future<ClientProgressResponseModel> getUserProgress({
    required int visitNumber,
  }) async {
    final response = await _apiService.get(
      ApiEndpoints.userProgress,
      queryParameters: {'visitNumber': visitNumber},
    );
    return ClientProgressResponseModel.fromJson(response.data as Map<String, dynamic>);
  }
}
