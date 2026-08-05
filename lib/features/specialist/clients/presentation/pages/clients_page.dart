import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/loader_hud.dart';
import 'package:fitness_day/core/widgets/errors/app_error_view.dart';
import 'package:fitness_day/core/widgets/top_centered_constrained_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/widgets/app_header.dart';
import 'package:fitness_day/core/widgets/app_search_bar.dart';
import 'package:fitness_day/core/widgets/app_segmented_control.dart';
import 'package:fitness_day/core/widgets/app_drawer.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/features/specialist/clients/presentation/manager/specialist_clients_cubit.dart';
import 'package:fitness_day/features/specialist/clients/presentation/manager/specialist_clients_state.dart';
import 'package:fitness_day/features/specialist/clients/presentation/pages/client_profile_page.dart';
import 'package:go_router/go_router.dart';
import 'package:fitness_day/core/routes/specialist_routes/app_routes.dart';
import 'package:fitness_day/features/specialist/clients/presentation/widgets/client_card.dart';

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

  String _getStatusString(int index) {
    if (index == 0) return 'ACTIVE';
    if (index == 1) return 'NEEDS_FOLLOW_UP';
    return 'SUBSCRIPTION_ENDED';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SpecialistClientsCubit>(
      create: (context) => getIt<SpecialistClientsCubit>()
        ..getSpecialistClients(status: _getStatusString(_selectedTabIndex)),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          context.go(SpecialistAppRoutes.home);
        },
        child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.visitsBackgroundGradient,
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
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
                              context.read<SpecialistClientsCubit>().getSpecialistClients(
                                    status: _getStatusString(_selectedTabIndex),
                                    search: val,
                                  );
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
                              context.read<SpecialistClientsCubit>().getSpecialistClients(
                                    status: _getStatusString(index),
                                    search: _searchController.text,
                                  );
                            },
                          ),
                        ),

                        SizedBox(height: 10.h),

                        // 4. Client Cards List
                        Expanded(
                          child: BlocBuilder<SpecialistClientsCubit, SpecialistClientsState>(
                            builder: (context, state) {
                              if (state is SpecialistClientsLoading) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primary,
                                  ),
                                );
                              } else if (state is SpecialistClientsFailure) {
                                return AppErrorView(
                                  error: state.error,
                                  message: state.message,
                                  onRetry: () => context.read<SpecialistClientsCubit>().getSpecialistClients(
                                        status: _getStatusString(_selectedTabIndex),
                                        search: _searchController.text,
                                      ),
                                );
                              } else if (state is SpecialistClientsSuccess) {
                                final clientResponse = state.data;
                                final clientsList = clientResponse.data ?? [];

                                ClientStatus cardStatus;
                                if (_selectedTabIndex == 0) {
                                  cardStatus = ClientStatus.active;
                                } else if (_selectedTabIndex == 1) {
                                  cardStatus = ClientStatus.needsFollowUp;
                                } else {
                                  cardStatus = ClientStatus.expired;
                                }

                                if (clientsList.isEmpty) {
                                  return Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 32.w),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.groups_rounded,
                                            size: 120.sp,
                                            color: AppColors.primary.withValues(alpha: 0.15),
                                          ),
                                          SizedBox(height: 24.h),
                                          Text(
                                            'clients_page.empty_title'.tr(),
                                            style: TextStyleManager.style16Bold.copyWith(
                                              color: AppColors.primary,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          SizedBox(height: 12.h),
                                          Text(
                                            'clients_page.empty_subtitle'.tr(),
                                            style: TextStyleManager.style13Medium.copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                return ListView.builder(
                                  padding: EdgeInsets.only(
                                    bottom: 24.h,
                                    left: 16.w,
                                    right: 16.w,
                                    top: 10.h,
                                  ),
                                  itemCount: clientsList.length,
                                  itemBuilder: (context, index) {
                                    final clientItem = clientsList[index];
                                    final user = clientItem.user;
                                    return ClientCard(
                                      clientName: user?.name ?? '',
                                      currentWeight: clientItem.currentWeight?.toInt().toString() ?? '',
                                      goal: clientItem.goal ?? '',
                                      lastVisit: '',
                                      status: cardStatus,
                                      commitmentRate: clientItem.adherenceRate?.toInt(),
                                      avatarUrl: user?.image,
                                      onViewProfile: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ClientProfilePage(userId: user?.id ?? ''),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              }
                              return const SizedBox.shrink();
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
        ),
      ),
    ));
  }
}
