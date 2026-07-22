import 'package:fitness_day/core/entities/task_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:fitness_day/core/cache/app_cache.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/features/user/user_home/presentation/manager/user_home_state.dart';
import 'package:fitness_day/features/user/user_home/domain/entities/article_data.dart';
import 'package:fitness_day/features/user/user_home/domain/usecases/user_home_usecases.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/core/routes/user_routes/app_routes.dart';

class UserHomeCubit extends Cubit<UserHomeState> {
  final GetUserHomeDataUseCase getUserHomeDataUseCase;
  final GetArticlesUseCase getArticlesUseCase;

  UserHomeCubit({
    required this.getUserHomeDataUseCase,
    required this.getArticlesUseCase,
  }) : super(UserHomeLoading());

  Future<void> loadHomeData() async {
    emit(UserHomeLoading());

    // Fetch both in parallel
    final results = await Future.wait([
      getUserHomeDataUseCase(),
      getArticlesUseCase(),
    ]);

    final homeResult = results[0];
    final articlesResult = results[1];

    if (homeResult is FailureResult) {
      emit(UserHomeError((homeResult as FailureResult).failure.message));
      return;
    }

    final homeData = (homeResult as Success).data.data;
    final bool isSubscribed = homeData?.subscription != null;

    // Cache subscription status so every screen (market, profile…) can read it
    // without having to depend on UserHomeCubit.
    getIt<AppCache>().saveIsSubscribed(isSubscribed);

    // Cache assessmentId for use in meal/workout detail screens
    final String? assessmentId = homeData?.dailyTasks?.assessmentId;
    if (assessmentId != null && assessmentId.isNotEmpty) {
      getIt<AppCache>().saveAssessmentId(assessmentId);
    }

    // Map dailyTasks to TaskData list
    final List<TaskData> tasks = [];

    final String dailyAssessmentId = homeData?.dailyTasks?.assessmentId ?? assessmentId ?? '';
    final int dayNumber = homeData?.dailyTasks?.dayNumber ?? 1;

    if (homeData?.dailyTasks?.currentMeal != null) {
      final meal = homeData!.dailyTasks!.currentMeal!;
      final String mealId = meal['mealId'] as String? ?? '';
      tasks.add(TaskData(
        imagePath: meal['image'] ?? '',
        title: meal['categoryName'] ?? '',
        description: meal['name'] ?? '',
        time: _formatTime(meal['time']),
        extraLabel: '${meal['calories'] ?? 0}',
        extraUnit: 'Kcal',
        extraIcon: Icons.local_fire_department,
        done: meal['isCompleted'] ?? false,
        route: UserAppRoutes.mealDetails,
        routeExtra: {
          'mealId': mealId,
          'assessmentId': dailyAssessmentId,
          'dayNumber': dayNumber,
        },
      ));
    }

    if (homeData?.dailyTasks?.currentWorkoutItem != null) {
      final workout = homeData!.dailyTasks!.currentWorkoutItem!;
      final String workoutItemId = workout['workoutItemId'] as String? ?? '';
      tasks.add(TaskData(
        imagePath: workout['photo'] ?? '',
        title: workout['name'] ?? '',
        description: workout['description'] ?? '',
        time: _formatTime(workout['time']),
        extraLabel: '${workout['completedSets'] ?? 0}',
        extraUnit: '${workout['totalSets'] ?? 0}',
        extraIcon: null,
        done: workout['isCompleted'] ?? false,
        isExerciseDialog: true,
        workoutItemId: workoutItemId,
        workoutDayNumber: dayNumber,
      ));
    }

    // NOTE: currentActivity is intentionally NOT added to tasks here.
    // home_page.dart renders it separately in Section 8 with its own
    // onDetailsPressed callback to avoid duplication.

    // Map articles
    List<ArticleData> articles = [];
    if (articlesResult is Success) {
      articles = ((articlesResult as Success).data.data as List)
          .map<ArticleData>((a) => a.toEntity())
          .toList();
    }

    emit(UserHomeLoaded(
      tasks: tasks,
      articles: articles,
      isSubscribed: isSubscribed,
      homeData: homeData,
    ));
  }

  String _formatTime(String? isoTime) {
    if (isoTime == null) return '';
    try {
      final dt = DateTime.parse(isoTime).toLocal();
      final hour = dt.hour;
      final minute = dt.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    } catch (_) {
      return '';
    }
  }
}
