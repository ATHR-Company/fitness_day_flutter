import 'package:flutter/material.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

class TaskSectionTitle extends StatelessWidget {
  final String title;
  const TaskSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        title,
        style: TextStyleManager.heading2.copyWith(
          color: AppColors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
