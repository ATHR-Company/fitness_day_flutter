import 'package:flutter/material.dart';

class TaskData {
  /// Server id of the item this card stands for — `mealId`, `workoutItemId` or
  /// `activityId` depending on the kind of task.
  ///
  /// Only used to route a [TaskProgressEvent] to the one card it belongs to.
  /// The ids were already present, but buried inside [routeExtra] under three
  /// different keys, which made matching a card impossible without knowing its
  /// type first.
  final String? taskId;

  final String imagePath;
  final String title;
  final String description;
  final String time;
  final String extraLabel;
  final String extraUnit;
  final IconData? extraIcon;
  final bool done;
  final bool isSvgImage;
  final String? route;
  final Object? routeExtra;
  final bool isExerciseDialog;
  final String? workoutItemId;
  final int? workoutDayNumber;
  final String? workoutAssessmentId;
  final VoidCallback? onDetailsPressed;

  const TaskData({
    this.taskId,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.time,
    required this.extraLabel,
    required this.extraUnit,
    required this.extraIcon,
    required this.done,
    this.isSvgImage = false,
    this.route,
    this.routeExtra,
    this.isExerciseDialog = false,
    this.workoutItemId,
    this.workoutDayNumber,
    this.workoutAssessmentId,
    this.onDetailsPressed,
  });

  TaskData copyWith({
    String? taskId,
    String? imagePath,
    String? title,
    String? description,
    String? time,
    String? extraLabel,
    String? extraUnit,
    IconData? extraIcon,
    bool? done,
    bool? isSvgImage,
    String? route,
    Object? routeExtra,
    bool? isExerciseDialog,
    String? workoutItemId,
    int? workoutDayNumber,
    String? workoutAssessmentId,
    VoidCallback? onDetailsPressed,
  }) {
    return TaskData(
      taskId: taskId ?? this.taskId,
      imagePath: imagePath ?? this.imagePath,
      title: title ?? this.title,
      description: description ?? this.description,
      time: time ?? this.time,
      extraLabel: extraLabel ?? this.extraLabel,
      extraUnit: extraUnit ?? this.extraUnit,
      extraIcon: extraIcon ?? this.extraIcon,
      done: done ?? this.done,
      isSvgImage: isSvgImage ?? this.isSvgImage,
      route: route ?? this.route,
      routeExtra: routeExtra ?? this.routeExtra,
      isExerciseDialog: isExerciseDialog ?? this.isExerciseDialog,
      workoutItemId: workoutItemId ?? this.workoutItemId,
      workoutDayNumber: workoutDayNumber ?? this.workoutDayNumber,
      workoutAssessmentId: workoutAssessmentId ?? this.workoutAssessmentId,
      onDetailsPressed: onDetailsPressed ?? this.onDetailsPressed,
    );
  }
}
