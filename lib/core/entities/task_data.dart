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
  final bool isExerciseDialog;
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
    this.isExerciseDialog = false,
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
    bool? isExerciseDialog,
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
      isExerciseDialog: isExerciseDialog ?? this.isExerciseDialog,
      onDetailsPressed: onDetailsPressed ?? this.onDetailsPressed,
    );
  }
}
