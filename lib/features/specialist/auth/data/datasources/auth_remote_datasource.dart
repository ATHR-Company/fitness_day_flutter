import 'package:fitness_day/core/network/api_service.dart';
import 'package:fitness_day/core/constant/api_endpoints.dart';
import 'package:fitness_day/features/specialist/auth/data/models/auth_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthModel> login(String phone, String password);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiService _apiService;

  AuthRemoteDataSourceImpl(this._apiService);

  @override
  Future<AuthModel> login(String phone, String password) async {
    final response = await _apiService.post(
      ApiEndpoints.specialistSignin,
      data: {
        'phone': phone,
        'password': password,
      },
    );
    return AuthModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> logout() async {
    await _apiService.post(ApiEndpoints.specialistSignout);
  }
}
