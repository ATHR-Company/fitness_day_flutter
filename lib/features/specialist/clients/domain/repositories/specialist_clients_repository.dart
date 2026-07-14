import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/specialist/clients/data/models/specialist_client_model.dart';

abstract class SpecialistClientsRepository {
  Future<ApiResult<SpecialistClientsListResponseModel>> getSpecialistClients({
    required int page,
    required int limit,
    required String status,
    String? search,
  });

  Future<ApiResult<SpecialistClientProfileResponseModel>> getSpecialistClientProfile({
    required String userId,
  });
}
