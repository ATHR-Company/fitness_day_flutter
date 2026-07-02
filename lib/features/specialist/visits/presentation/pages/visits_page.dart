import 'package:fitness_day/core/widgets/loader_hud.dart';
import 'package:fitness_day/core/widgets/top_centered_constrained_box.dart';
import 'package:fitness_day/features/specialist/visits/presentation/pages/visit_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/widgets/app_header.dart';
import 'package:fitness_day/core/widgets/app_search_bar.dart';
import 'package:fitness_day/core/widgets/app_segmented_control.dart';
import 'package:fitness_day/core/widgets/visit_card.dart';
import 'package:fitness_day/core/widgets/app_drawer.dart';

class VisitsPage extends StatefulWidget {
  const VisitsPage({super.key});

  @override
  State<VisitsPage> createState() => _VisitsPageState();
}

class _VisitsPageState extends State<VisitsPage> {
  int _selectedTabIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      endDrawer: const AppDrawer(),
      body: Builder(
        builder: (context) {
          return LoaderHud(
            isCall: false,
            child: SafeArea(
              child: TopCenteredConstrainedBox(
                horizontalPadding: 0,
                child: Column(
                children: [
                  SizedBox(height: 16.h),

                  // 1. Header
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: AppHeader(
                      title: 'visits.title'.tr(),
                      onMenuPressed: () {
                        Scaffold.of(context).openEndDrawer();
                      },
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // 2. Search Bar
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: AppSearchBar(
                      hintText: 'visits.search_hint'.tr(),
                      controller: _searchController,
                      onChanged: (val) {
                        // Handle search
                      },
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // 3. Segmented Control
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: AppSegmentedControl(
                      items: [
                        'visits.tab_upcoming'.tr(),
                        'visits.tab_history'.tr(),
                      ],
                      selectedIndex: _selectedTabIndex,
                      onItemSelected: (index) {
                        setState(() {
                          _selectedTabIndex = index;
                        });
                      },
                    ),
                  ),

                  SizedBox(height: 10.h),

                  // 4. Visit Cards List
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.all(20.h),
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 10.h),
                      itemCount: 3, // Dummy count
                      itemBuilder: (context, index) {
                        final timeRem = index == 0
                            ? 'visits.in_minutes'.tr(args: ['25'])
                            : '';
                        return VisitCard(
                          timeRemaining: timeRem,
                          title: 'visits.dummy_title'.tr(),
                          subtitle: 'visits.dummy_subtitle'.tr(),
                          personName: 'visits.dummy_client'.tr(),
                          visitTime:
                              '${'visits.today'.tr()} 4:30 ${'visits.pm'.tr()}',
                          location: 'visits.hq_location'.tr(),
                          buttonText: _selectedTabIndex == 0
                              ? 'visits.view_visit'.tr()
                              : 'visits.details'.tr(),
                          onViewPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VisitDetailsPage(isUpcoming: _selectedTabIndex == 0),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
              ),
            );
          },
        ),
      );
    }
}
