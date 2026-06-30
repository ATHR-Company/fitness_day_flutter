import 'package:fitness_day/features/specialist/auth/domain/entities/auth_entity.dart';

class AuthModel extends AuthEntity {
  const AuthModel({required super.token, required super.userId});

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(token: json['token'] ?? '', userId: json['userId'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'token': token, 'userId': userId};
  }
}
