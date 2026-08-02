import 'dart:async';

import 'package:fitness_day/core/entities/task_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:fitness_day/core/cache/app_cache.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/services/app_event_bus.dart';
import 'package:fitness_day/features/user/user_home/presentation/manager/user_home_state.dart';
import 'package:fitness_day/features/user/user_home/domain/entities/article_data.dart';
import 'package:fitness_day/features/user/user_home/domain/entities/subscription_package_data.dart';
import 'package:fitness_day/features/user/user_home/data/models/user_home_response_model.dart';
import 'package:fitness_day/features/user/user_home/domain/usecases/user_home_usecases.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/core/routes/user_routes/app_routes.dart';
import 'package:fitness_day/core/errors/app_error.dart';

class UserHomeCubit extends Cubit<UserHomeState> {
  final GetUserHomeDataUseCase getUserHomeDataUseCase;
  final GetArticlesUseCase getArticlesUseCase;

  /// Live patches from the detail screens — see [AppEventBus].
  late final StreamSubscription<AppEvent> _progressSub;

  UserHomeCubit({
    required this.getUserHomeDataUseCase,
    required this.getArticlesUseCase,
  }) : super(UserHomeLoading()) {
    _progressSub = getIt<AppEventBus>().stream.listen(_applyProgressEvent);
  }

  @override
  Future<void> close() {
    _progressSub.cancel();
    return super.close();
  }

  /// [silent] keeps the current screen on-screen while refetching instead of
  /// dropping to the shimmer, and leaves it there if the refetch fails.
  ///
  /// Returns the failure when there was one, `null` on success. A silent
  /// refresh has no other way to report: it deliberately emits nothing, so a
  /// caller that the *user* triggered — pull-to-refresh — would otherwise spin
  /// its indicator and then show absolutely nothing. The caller decides what to
  /// do with it; on home that is a snackbar, which reports the problem without
  /// taking the page away.
  Future<AppError?> loadHomeData({bool silent = false}) async {
    if (!silent) emit(UserHomeLoading());

    // Fetch both in parallel with typed results
    final homeResult = await getUserHomeDataUseCase();
    final articlesResult = await getArticlesUseCase();

    if (homeResult is FailureResult<UserHomeResponseModel>) {
      final AppError error = AppError.from(homeResult.failure);
      // A silent refresh must never replace good content with an error screen —
      // the user is still reading the page. It is reported to the caller
      // instead, which shows it over the content.
      if (!silent) {
        emit(UserHomeError(homeResult.failure.message, error: error));
      }
      return error;
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
        taskId: mealId,
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
        taskId: workoutItemId,
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

    // Plans come down with the home payload for unsubscribed users; without
    // this mapping the "choose a package" grid renders an empty block.
    final List<SubscriptionPackageData> packages = (homeData?.plans ?? [])
        .map<SubscriptionPackageData>((p) => SubscriptionPackageData(
              id: p.id,
              imageUrl: p.coverPhoto,
              name: p.name,
              currentPrice: p.price.round(),
              oldPrice: p.compareAtPrice?.round() ?? 0,
              badge: p.badge,
            ))
        .toList();

    emit(UserHomeLoaded(
      tasks: tasks,
      articles: articles,
      isSubscribed: isSubscribed,
      homeData: homeData,
      packages: packages,
    ));
    return null;
  }

  // ─── Live patching ────────────────────────────────────────────────────────

  /// Applies one server-confirmed change to the card it belongs to, in place.
  ///
  /// This is what replaces the full `loadHomeData()` that used to run every time
  /// the user came back from a detail screen: no request, no shimmer, and the
  /// scroll position is untouched because only the one card's data changes.
  void _applyProgressEvent(AppEvent event) {
    final UserHomeState current = state;
    if (current is! UserHomeLoaded) return;

    if (event is ArticleChanged) {
      _applyArticleEvent(current, event);
      return;
    }
    if (event is! TaskProgressEvent) return;

    final dailyTasks = current.homeData?.dailyTasks;
    if (dailyTasks == null) return;

    // Home only ever shows the current assessment's current day. An event from
    // another day — the user browsing day 4 in today-tasks, say — is not about
    // any card on this screen.
    if (dailyTasks.assessmentId != event.assessmentId ||
        dailyTasks.dayNumber != event.dayNumber) {
      return;
    }

    switch (event) {
      case ActivityProgressChanged():
        final activity = dailyTasks.currentActivity;
        if (activity == null || activity['activityId'] != event.activityId) {
          return;
        }
        // The card reads straight out of this map (home_page_content section 8),
        // so the patch has to land on the map, not on `tasks`.
        final patched = Map<String, dynamic>.from(activity)
          ..['currentProgress'] = event.currentProgress
          ..['goal'] = event.goal
          ..['isCompleted'] = event.isCompleted;
        emit(_copyLoaded(
          current,
          homeData: current.homeData!
              .copyWith(dailyTasks: dailyTasks.copyWith(currentActivity: patched)),
        ));

      case MealProgressChanged():
        emit(_copyLoaded(
          current,
          tasks: _patchTask(
            current.tasks,
            event.taskId,
            (task) => task.copyWith(done: event.isCompleted),
          ),
        ));

      case WorkoutProgressChanged():
        emit(_copyLoaded(
          current,
          tasks: _patchTask(
            current.tasks,
            event.taskId,
            (task) => task.copyWith(
              done: event.isCompleted,
              extraLabel: '${event.completedSets}',
              extraUnit: '${event.totalSets}',
            ),
          ),
        ));
    }
  }

  /// Updates the home's article strip after the details screen read the article
  /// (which is what bumps its view count) or its bookmark was tapped anywhere.
  void _applyArticleEvent(UserHomeLoaded current, ArticleChanged event) {
    final int index =
        current.articles.indexWhere((a) => a.id == event.articleId);
    if (index == -1) return;

    final List<ArticleData> next = List<ArticleData>.of(current.articles);
    next[index] =
        next[index].copyWith(views: event.views, isSaved: event.isSaved);
    emit(_copyLoaded(current, articles: next));
  }

  /// Returns a new list with the matching card replaced, or the original list
  /// untouched when nothing matched — emitting an identical-but-new list would
  /// rebuild the whole page for nothing.
  List<TaskData> _patchTask(
    List<TaskData> tasks,
    String taskId,
    TaskData Function(TaskData) patch,
  ) {
    if (taskId.isEmpty) return tasks;
    final int index = tasks.indexWhere((t) => t.taskId == taskId);
    if (index == -1) return tasks;
    final List<TaskData> next = List<TaskData>.of(tasks);
    next[index] = patch(next[index]);
    return next;
  }

  UserHomeLoaded _copyLoaded(
    UserHomeLoaded state, {
    List<TaskData>? tasks,
    List<ArticleData>? articles,
    UserHomeDataModel? homeData,
  }) {
    return UserHomeLoaded(
      packages: state.packages,
      tasks: tasks ?? state.tasks,
      articles: articles ?? state.articles,
      isSubscribed: state.isSubscribed,
      homeData: homeData ?? state.homeData,
    );
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
