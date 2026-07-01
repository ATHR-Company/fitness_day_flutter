import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/widgets/custom_button.dart';
import 'package:fitness_day/core/widgets/custom_outlined_button.dart';
import 'package:fitness_day/core/widgets/message_icon_button.dart';
import 'package:fitness_day/core/widgets/upcoming_visit_show_screen.dart';
import 'package:fitness_day/features/shared/conversations/presentation/pages/conversations_page.dart';
import 'package:fitness_day/core/widgets/reschedule_visit_dialog.dart';

class UserUpcomingVisitPage extends StatelessWidget {
  const UserUpcomingVisitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return UpcomingVisitShowScreen(
      title: 'تفاصيل الزيارة القادمة',
      trailingWidget: MessageIconButton(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ConversationsPage(),
            ),
          );
        },
      ),
      visitTimeRemaining: '',
      visitTitle: 'متابعة أسبوعية',
      visitSubtitle: 'كشف انبودي ، تجديد باقة الشهر',
      personName: 'د/ محمد عبدالله',
      personNameLabel: 'اسم الأخصائي :',
      visitTime: 'اليوم 4:30 مساءً',
      visitLocation: 'مقر العيادة - المنصورة',
      visitGoalTitle: 'الهدف من الزيارة',
      visitGoals: const [
        'قياس الوزن ومعدل الدهون',
        'مراجعة النظام الغذائي وتعديله',
        'تقييم مستوى اللياقة الحالي',
        'وضع خطة تدريب للأسبوع القادم',
      ],
      bottomAction: Row(
        children: [
          Expanded(
            child: CustomButton(
              text: 'تغيير المكان',
              color: AppColors.primary,
              onPressed: () {},
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: CustomOutlinedButton(
              text: 'تغيير الميعاد',
              onPressed: () {
                showRescheduleDialog(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
