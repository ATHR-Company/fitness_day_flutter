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
}
