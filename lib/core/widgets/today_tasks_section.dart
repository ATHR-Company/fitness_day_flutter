import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/widgets/exercise_details_dialog.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_text_styles.dart';
import 'package:fitness_day/core/entities/task_data.dart';
import 'package:fitness_day/core/widgets/task_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Tasks List — default sample data
// ─────────────────────────────────────────────────────────────────────────────
class TodayTasksSection extends StatelessWidget {
  final List<TaskData> tasks;
  final bool plainBackground;

  const TodayTasksSection({
    super.key,
    required this.tasks,
    this.plainBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: tasks
          .map(
            (task) => Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: TaskCard(task: task, plainBackground: plainBackground),
            ),
          )
          .toList(),
    );
  }
}
