import 'package:fitness_day/core/errors/error_handler.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/specialist/clients/data/datasources/specialist_clients_remote_datasource.dart';
import 'package:fitness_day/features/specialist/clients/data/models/specialist_client_model.dart';
import 'package:fitness_day/features/specialist/clients/data/models/client_assessment_model.dart';
import 'package:fitness_day/features/specialist/clients/domain/repositories/specialist_clients_repository.dart';

class SpecialistClientsRepositoryImpl implements SpecialistClientsRepository {
  final SpecialistClientsRemoteDataSource remoteDataSource;

  SpecialistClientsRepositoryImpl(this.remoteDataSource);

  @override
  Future<ApiResult<SpecialistClientsListResponseModel>> getSpecialistClients({
    required int page,
    required int limit,
    required String status,
    String? search,
  }) async {
    try {
      final response = await remoteDataSource.getSpecialistClients(
        page: page,
        limit: limit,
        status: status,
        search: search,
      );
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<SpecialistClientProfileResponseModel>> getSpecialistClientProfile({
    required String userId,
  }) async {
    try {
      final response = await remoteDataSource.getSpecialistClientProfile(userId: userId);
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<ClientAssessmentsResponseModel>> getUpcomingAssessments({
    required String userId,
    required int page,
    required int limit,
  }) async {
    try {
      final response = await remoteDataSource.getUpcomingAssessments(
        userId: userId, page: page, limit: limit,
      );
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<ClientAssessmentsResponseModel>> getPreviousAssessments({
    required String userId,
    required int page,
    required int limit,
  }) async {
    try {
      final response = await remoteDataSource.getPreviousAssessments(
        userId: userId, page: page, limit: limit,
      );
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }
}

