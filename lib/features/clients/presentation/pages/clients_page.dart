import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/widgets/app_header.dart';
import 'package:fitness_day/core/widgets/app_search_bar.dart';
import 'package:fitness_day/core/widgets/app_segmented_control.dart';
import 'package:fitness_day/features/clients/presentation/pages/client_profile_page.dart';
import 'package:fitness_day/features/clients/presentation/widgets/client_card.dart';
import 'package:fitness_day/core/widgets/app_drawer.dart';

class ClientsPage extends StatefulWidget {
  const ClientsPage({super.key});

  @override
  State<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
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
      endDrawer: const AppDrawer(),
      body: Builder(
        builder: (context) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppColors.visitsBackgroundGradient,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  SizedBox(height: 16.h),
                  
                  // 1. Header
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: AppHeader(
                      title: 'clients_page.title'.tr(),
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
                      hintText: 'clients_page.search_hint'.tr(),
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
                        'clients_page.tab_active'.tr(),
                        'clients_page.tab_needs_follow_up'.tr(),
                        'clients_page.tab_expired'.tr(),
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
                  
                  // 4. Client Cards List
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.only(bottom: 24.h, left: 16.w, right: 16.w, top: 10.h),
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        ClientStatus status;
                        int commitment;
                        
                        if (_selectedTabIndex == 0) {
                          status = ClientStatus.active;
                          commitment = 85;
                        } else if (_selectedTabIndex == 1) {
                          status = ClientStatus.needsFollowUp;
                          commitment = 10;
                        } else {
                          status = ClientStatus.expired;
                          commitment = 0;
                        }

                        return ClientCard(
                          clientName: 'محمد عبدالله',
                          currentWeight: '58',
                          goal: 'زيادة الوزن',
                          lastVisit: '3/6/2026 - 3:50 ص',
                          status: status,
                          commitmentRate: commitment,
                          onViewProfile: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ClientProfilePage(),
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
          );
        }
      ),
    );
  }
}
