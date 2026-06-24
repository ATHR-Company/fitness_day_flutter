import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/visit_card.dart';

class ClientVisitsTab extends StatelessWidget {
  const ClientVisitsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      children: [
        SizedBox(height: 8.h),
        Text(
          'clients_page.upcoming_visit'.tr(),
          style: TextStyleManager.style14Bold,
        ),
        SizedBox(height: 16.h),
        VisitCard(
          timeRemaining: 'clients_page.commitment_rate'.tr(args: ['85']),
          title: 'home.weekly_follow_up'.tr(),
          subtitle: 'home.weekly_follow_up_desc'.tr(),
          clientName: 'محمد عبدالله',
          visitTime: 'اليوم 4:30 مساءا',
          location: 'في مقر يوم الرشاقة',
          buttonText: 'home.view_visit'.tr(),
          onViewPressed: () {},
          secondaryButtonText: 'home.reschedule'.tr(),
          onSecondaryPressed: () {},
        ),
        SizedBox(height: 24.h),
        Text(
          'clients_page.past_visits'.tr(),
          style: TextStyleManager.style14Bold,
        ),
        SizedBox(height: 16.h),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 2,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: VisitCard(
                timeRemaining: '',
                title: 'home.weekly_follow_up'.tr(),
                subtitle: 'home.weekly_follow_up_desc'.tr(),
                clientName: 'محمد عبدالله',
                visitTime: 'اليوم 4:30 مساءا',
                location: 'في مقر يوم الرشاقة',
                buttonText: 'clients_page.details'.tr(),
                onViewPressed: () {},
              ),
            );
          },
        ),
      ],
    );
  }
}
