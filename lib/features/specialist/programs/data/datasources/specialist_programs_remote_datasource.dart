import 'package:fitness_day/core/constant/api_endpoints.dart';
import 'package:fitness_day/core/network/api_service.dart';
import 'package:fitness_day/features/specialist/programs/data/models/specialist_program_model.dart';

/// Read-only. Applying a week is a *visit* write and lives in
/// `SpecialistVisitsRemoteDataSource` alongside the other endpoints that
/// change a visit's plan.
abstract class SpecialistProgramsRemoteDataSource {
  Future<SpecialistProgramsResponseModel> getPrograms({
    required int page,
    required int limit,
    String? search,
  });

  Future<SpecialistProgramWeeksResponseModel> getProgramWeeks({
    required String programId,
  });
}

class SpecialistProgramsRemoteDataSourceImpl
    implements SpecialistProgramsRemoteDataSource {
  final ApiService _apiService;

  SpecialistProgramsRemoteDataSourceImpl(this._apiService);

  @override
  Future<SpecialistProgramsResponseModel> getPrograms({
    required int page,
    required int limit,
    String? search,
  }) async {
    final response = await _apiService.get(
      ApiEndpoints.specialistPrograms,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    return SpecialistProgramsResponseModel.fromJson(
        response.data as Map<String, dynamic>);
  }

  @override
  Future<SpecialistProgramWeeksResponseModel> getProgramWeeks({
    required String programId,
  }) async {
    final response =
        await _apiService.get(ApiEndpoints.specialistProgramWeeks(programId));
    return SpecialistProgramWeeksResponseModel.fromJson(
        response.data as Map<String, dynamic>);
  }
}
