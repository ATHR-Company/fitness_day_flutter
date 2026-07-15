import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/specialist/profile/data/models/specialist_profile_model.dart';

abstract class SpecialistProfileRepository {
  Future<ApiResult<SpecialistProfileResponseModel>> getSpecialistProfile();
  Future<ApiResult<SpecialistProfileResponseModel>> updateSpecialistProfile({
    required String name,
    String? avatarPath,
  });
}
