import 'package:dio/dio.dart';
import 'package:fitness_day/core/network/api_service.dart';
import 'package:fitness_day/core/constant/api_endpoints.dart';
import 'package:fitness_day/features/specialist/profile/data/models/specialist_profile_model.dart';

abstract class SpecialistProfileRemoteDataSource {
  Future<SpecialistProfileResponseModel> getSpecialistProfile();
  Future<SpecialistProfileResponseModel> updateSpecialistProfile({
    required String name,
    String? avatarPath,
  });
}

class SpecialistProfileRemoteDataSourceImpl implements SpecialistProfileRemoteDataSource {
  final ApiService _apiService;

  SpecialistProfileRemoteDataSourceImpl(this._apiService);

  @override
  Future<SpecialistProfileResponseModel> getSpecialistProfile() async {
    final response = await _apiService.get(ApiEndpoints.specialistProfile);
    return SpecialistProfileResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<SpecialistProfileResponseModel> updateSpecialistProfile({
    required String name,
    String? avatarPath,
  }) async {
    final formData = FormData.fromMap({
      'name': name,
      if (avatarPath != null)
        'avatar': await MultipartFile.fromFile(
          avatarPath,
          filename: avatarPath.split('/').last,
        ),
    });

    final response = await _apiService.patch(
      ApiEndpoints.updateSpecialistProfile,
      data: formData,
    );
    return SpecialistProfileResponseModel.fromJson(response.data as Map<String, dynamic>);
  }
}
