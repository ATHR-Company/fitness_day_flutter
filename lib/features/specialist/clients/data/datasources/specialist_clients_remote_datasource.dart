import 'package:fitness_day/core/constant/api_endpoints.dart';
import 'package:fitness_day/core/network/api_service.dart';
import 'package:fitness_day/features/specialist/clients/data/models/specialist_client_model.dart';
import 'package:fitness_day/features/specialist/clients/data/models/client_assessment_model.dart';

abstract class SpecialistClientsRemoteDataSource {
  Future<SpecialistClientsListResponseModel> getSpecialistClients({
    required int page,
    required int limit,
    required String status,
    String? search,
  });

  Future<SpecialistClientProfileResponseModel> getSpecialistClientProfile({
    required String userId,
  });

  Future<ClientAssessmentsResponseModel> getUpcomingAssessments({
    required String userId,
    required int page,
    required int limit,
  });

  Future<ClientAssessmentsResponseModel> getPreviousAssessments({
    required String userId,
    required int page,
    required int limit,
  });
}

class SpecialistClientsRemoteDataSourceImpl implements SpecialistClientsRemoteDataSource {
  final ApiService _apiService;

  SpecialistClientsRemoteDataSourceImpl(this._apiService);

  @override
  Future<SpecialistClientsListResponseModel> getSpecialistClients({
    required int page,
    required int limit,
    required String status,
    String? search,
  }) async {
    final queryParams = {
      'page': page,
      'limit': limit,
      'status': status,
      if (search != null && search.isNotEmpty) 'search': search,
    };

    final response = await _apiService.get(
      ApiEndpoints.specialistClients,
      queryParameters: queryParams,
    );

    return SpecialistClientsListResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<SpecialistClientProfileResponseModel> getSpecialistClientProfile({
    required String userId,
  }) async {
    final response = await _apiService.get(
      ApiEndpoints.specialistClientProfile(userId),
    );

    return SpecialistClientProfileResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ClientAssessmentsResponseModel> getUpcomingAssessments({
    required String userId,
    required int page,
    required int limit,
  }) async {
    final response = await _apiService.get(
      ApiEndpoints.specialistClientUpcomingAssessments(userId),
      queryParameters: {'page': page, 'limit': limit},
    );
    return ClientAssessmentsResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ClientAssessmentsResponseModel> getPreviousAssessments({
    required String userId,
    required int page,
    required int limit,
  }) async {
    final response = await _apiService.get(
      ApiEndpoints.specialistClientPreviousAssessments(userId),
      queryParameters: {'page': page, 'limit': limit},
    );
    return ClientAssessmentsResponseModel.fromJson(response.data as Map<String, dynamic>);
  }
}

