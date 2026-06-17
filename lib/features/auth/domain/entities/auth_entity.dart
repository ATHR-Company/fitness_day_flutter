import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String token;
  final String userId;

  const AuthEntity({
    required this.token,
    required this.userId,
  });

  @override
  List<Object?> get props => [token, userId];
}
