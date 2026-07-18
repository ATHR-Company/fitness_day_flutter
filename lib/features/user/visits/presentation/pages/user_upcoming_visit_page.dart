import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/widgets/custom_button.dart';
import 'package:fitness_day/core/widgets/custom_outlined_button.dart';
import 'package:fitness_day/core/widgets/message_icon_button.dart';
import 'package:fitness_day/core/widgets/upcoming_visit_show_screen.dart';
import 'package:fitness_day/core/widgets/reschedule_visit_dialog.dart';
import 'package:fitness_day/generated/locale_keys.g.dart';

import '../../../../shared/conversations/presentation/pages/chat_details_page.dart';

class UserUpcomingVisitPage extends StatelessWidget {
  final String assessmentId;
  final int dayNumber;

  const UserUpcomingVisitPage({
    super.key,
    required this.assessmentId,
    required this.dayNumber,
  });

  @override
  Widget build(BuildContext context) {
    return UpcomingVisitShowScreen(
      title: LocaleKeys.visits_upcoming_visit_title.tr(),
      trailingWidget: MessageIconButton(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatDetailsPage()),
          );
        },
      ),
      visitTimeRemaining: '',
      visitTitle: LocaleKeys.visits_dummy_title.tr(),
      visitSubtitle: LocaleKeys.visits_upcoming_visit_subtitle.tr(),
      personName: LocaleKeys.visits_specialist_name_mock.tr(),
      personNameLabel: LocaleKeys.visits_specialist_name_label.tr(),
      visitTime:
          '${LocaleKeys.visits_today.tr()} 4:30 ${LocaleKeys.visits_pm.tr()}',
      visitLocation: LocaleKeys.visits_clinic_location_mansoura.tr(),
      visitGoalTitle: LocaleKeys.visit_details_visit_goal_title.tr(),
      visitGoals: [
        LocaleKeys.visits_upcoming_goal_1.tr(),
        LocaleKeys.visits_upcoming_goal_2.tr(),
        LocaleKeys.visits_upcoming_goal_3.tr(),
        LocaleKeys.visits_upcoming_goal_4.tr(),
      ],
      bottomAction: Row(
        children: [
          Expanded(
            child: CustomButton(
              text: LocaleKeys.visits_change_location_button.tr(),
              color: AppColors.primary,
              onPressed: () {},
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: CustomOutlinedButton(
              text: LocaleKeys.visits_change_time_button.tr(),
              onPressed: () {
                showRescheduleDialog(context, assessmentId);
              },
            ),
          ),
        ],
      ),
    );
  }
}
