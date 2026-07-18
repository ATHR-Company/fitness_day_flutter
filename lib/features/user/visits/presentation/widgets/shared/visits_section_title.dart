import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

/// A bold, start-aligned section header (e.g. "Nutrition", "Exercises").
/// Automatically respects the current text direction (RTL/LTR).
class VisitsSectionTitle extends StatelessWidget {
  final String title;

  const VisitsSectionTitle({super.key, required this.title});

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
