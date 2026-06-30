import 'package:equatable/equatable.dart';

abstract class UserHomeState extends Equatable {
  const UserHomeState();

  @override
  List<Object?> get props => [];
}

class UserHomeLoading extends UserHomeState {}

class UserHomeLoaded extends UserHomeState {
  final List<dynamic> packages;
  final List<dynamic> tasks;
  final List<dynamic> articles;
  final bool isSubscribed;

  const UserHomeLoaded({
    required this.packages,
    required this.tasks,
    required this.articles,
    this.isSubscribed = true,
  });

  @override
  List<Object?> get props => [packages, tasks, articles, isSubscribed];
}

class UserHomeError extends UserHomeState {
  final String message;

  const UserHomeError(this.message);

  @override
  List<Object?> get props => [message];
}
