import 'package:equatable/equatable.dart';
import 'package:fitness_day/core/entities/task_data.dart';

import 'package:fitness_day/features/user/user_home/domain/entities/article_data.dart';
import 'package:fitness_day/features/user/user_home/domain/entities/subscription_package_data.dart';

import 'package:fitness_day/features/user/user_home/data/models/user_home_response_model.dart';
import 'package:fitness_day/core/errors/app_error.dart';

abstract class UserHomeState extends Equatable {
  const UserHomeState();

  @override
  List<Object?> get props => [];
}

class UserHomeLoading extends UserHomeState {}

class UserHomeLoaded extends UserHomeState {
  /// Plans offered to unsubscribed users, mapped from `/user-home`'s `plans`.
  final List<SubscriptionPackageData> packages;
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
  List<Object?> get props => [
        List<SubscriptionPackageData>.from(packages),
        tasks,
        articles,
        isSubscribed,
        homeData,
      ];
}

class UserHomeError extends UserHomeState {
  final String message;

  /// Typed form of the failure, so the screen can decide between a
  /// full-screen retry and a message. Null on states not yet migrated.
  final AppError? error;

  const UserHomeError(this.message, {this.error});

  @override
  List<Object?> get props => [message, error];
}
