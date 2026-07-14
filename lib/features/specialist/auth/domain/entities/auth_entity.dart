import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String token;
  final String refreshToken;
  final String userId;

  const AuthEntity({
    required this.token,
    this.refreshToken = '',
    required this.userId,
  });

  @override
  List<Object?> get props => [token, refreshToken, userId];
}
