import 'package:fitness_day/features/auth/data/models/auth_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthModel> login(String phone, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<AuthModel> login(String phone, String password) async {
    // Mocking an API call
    await Future.delayed(const Duration(seconds: 2));
    
    if (phone.isNotEmpty && password.isNotEmpty) {
      return const AuthModel(token: 'mock_token', userId: 'mock_user_id');
    } else {
      throw Exception('Invalid credentials');
    }
  }
}
