import 'package:flutter/material.dart';

class TaskData {
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
  final VoidCallback? onDetailsPressed;

  const TaskData({
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
    this.onDetailsPressed,
  });

  TaskData copyWith({
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
    VoidCallback? onDetailsPressed,
  }) {
    return TaskData(
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
      onDetailsPressed: onDetailsPressed ?? this.onDetailsPressed,
    );
  }
}
