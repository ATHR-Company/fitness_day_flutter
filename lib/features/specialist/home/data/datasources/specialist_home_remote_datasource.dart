import 'package:fitness_day/core/network/api_service.dart';
import 'package:fitness_day/core/constant/api_endpoints.dart';
import 'package:fitness_day/features/specialist/home/data/models/specialist_home_model.dart';

abstract class SpecialistHomeRemoteDataSource {
  Future<SpecialistHomeResponseModel> getSpecialistHomeData();
}

class SpecialistHomeRemoteDataSourceImpl implements SpecialistHomeRemoteDataSource {
  final ApiService _apiService;

  SpecialistHomeRemoteDataSourceImpl(this._apiService);

  @override
  Future<SpecialistHomeResponseModel> getSpecialistHomeData() async {
    final response = await _apiService.get(ApiEndpoints.specialistHome);
    return SpecialistHomeResponseModel.fromJson(response.data as Map<String, dynamic>);
  }
}
