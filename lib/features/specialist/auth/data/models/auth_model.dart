import 'package:fitness_day/features/specialist/auth/domain/entities/auth_entity.dart';

class AuthModel extends AuthEntity {
  const AuthModel({
    required super.token,
    super.refreshToken = '',
    required super.userId,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    if (data != null) {
      return AuthModel(
        token: data['accessToken'] as String? ?? '',
        refreshToken: data['refreshToken'] as String? ?? '',
        userId: data['userId'] as String? ?? '',
      );
    }
    return AuthModel(
      token: json['token'] as String? ?? json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refreshToken': refreshToken,
      'userId': userId,
    };
  }
}
