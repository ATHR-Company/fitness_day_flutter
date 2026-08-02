import 'package:equatable/equatable.dart';
import 'package:fitness_day/features/specialist/auth/domain/entities/auth_entity.dart';
import 'package:fitness_day/core/errors/app_error.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final AuthEntity user;

  const AuthSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthFailure extends AuthState {
  final String message;

  /// Typed form of the failure, so the screen can decide between a
  /// full-screen retry and a message. Null on states not yet migrated.
  final AppError? error;

  const AuthFailure(this.message, {this.error});

  @override
  List<Object?> get props => [message, error];
}

class AuthLoggedOut extends AuthState {}
