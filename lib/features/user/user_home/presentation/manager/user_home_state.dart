import 'package:equatable/equatable.dart';
import 'package:fitness_day/core/entities/task_data.dart';

import 'package:fitness_day/features/user/user_home/domain/entities/article_data.dart';
import 'package:fitness_day/features/user/user_home/domain/entities/subscription_package_data.dart';

import 'package:fitness_day/features/user/user_home/data/models/user_home_response_model.dart';

abstract class UserHomeState extends Equatable {
  const UserHomeState();

  @override
  List<Object?> get props => [];
}

class UserHomeLoading extends UserHomeState {}

class UserHomeLoaded extends UserHomeState {
  final List<SubscriptionPackageData> packages; // Fallback or loaded separately
  final List<TaskData> tasks;
  final List<ArticleData> articles;
  final bool isSubscribed;
  final UserHomeDataModel? homeData;

  const UserHomeLoaded({
    this.packages = const [],
    required this.tasks,
    required this.articles,
    this.isSubscribed = true,
    this.homeData,
  });

  @override
  List<Object?> get props => [packages, tasks, articles, isSubscribed, homeData];
}

class UserHomeError extends UserHomeState {
  final String message;

  const UserHomeError(this.message);

  @override
  List<Object?> get props => [message];
}
