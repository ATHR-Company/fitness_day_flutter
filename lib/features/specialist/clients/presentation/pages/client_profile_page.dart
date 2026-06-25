import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/shared/widgets/app_segmented_control.dart';
import 'package:fitness_day/features/specialist/clients/presentation/widgets/client_profile/tabs/client_data_tab.dart';
import 'package:fitness_day/features/specialist/clients/presentation/widgets/client_profile/tabs/client_visits_tab.dart';
import 'package:fitness_day/features/specialist/clients/presentation/widgets/client_profile/tabs/client_progress_tab.dart';

class ClientProfilePage extends StatefulWidget {
  const ClientProfilePage({super.key});

  @override
  State<ClientProfilePage> createState() => _ClientProfilePageState();
}

class _ClientProfilePageState extends State<ClientProfilePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB), // Light grey background like in design
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'clients_page.client_profile'.tr(),
          style: TextStyleManager.style15Medium.copyWith(
            color: AppColors.black,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.black, size: 20.sp),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: AppSegmentedControl(
              items: [
                'clients_page.client_data'.tr(),
                'clients_page.visits'.tr(),
                'clients_page.progress'.tr(),
              ],
              selectedIndex: _selectedIndex,
              onItemSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: _buildTabContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedIndex) {
      case 0:
        return const ClientDataTab();
      case 1:
        return const ClientVisitsTab();
      case 2:
        return const ClientProgressTab();
      default:
        return const SizedBox.shrink();
    }
  }
}
