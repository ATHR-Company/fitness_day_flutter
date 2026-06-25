import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/specialist/clients/presentation/widgets/client_profile/components/progress_chart.dart';
import 'package:fitness_day/features/specialist/clients/presentation/widgets/client_profile/components/stat_tile.dart';

class ClientProgressTab extends StatelessWidget {
  const ClientProgressTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      children: [
        SizedBox(height: 8.h),
        const ProgressChart(),
        SizedBox(height: 32.h),
        Text(
          'clients_page.visit_summary'.tr(),
          style: TextStyleManager.style14Bold,
        ),
        SizedBox(height: 16.h),
        StatTile(
          label: 'clients_page.weight_short'.tr(),
          value: '60',
          measurement: 'clients_page.kg'.tr(),
          icon: Icons.monitor_weight_outlined,
        ),
        StatTile(
          label: 'clients_page.height_short'.tr(),
          value: '167',
          measurement: 'clients_page.cm'.tr(),
          icon: Icons.height,
        ),
        StatTile(
          label: 'clients_page.ideal_weight_short'.tr(),
          value: '65',
          measurement: 'clients_page.kg'.tr(),
          icon: Icons.scale_outlined,
        ),
        StatTile(
          label: 'clients_page.body_mass_short'.tr(),
          value: '20.4',
          icon: Icons.accessibility_new,
        ),
        SizedBox(height: 24.h),
      ],
    );
  }
}
