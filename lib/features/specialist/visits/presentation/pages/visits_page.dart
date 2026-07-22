import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/widgets/app_header.dart';
import 'package:fitness_day/core/widgets/app_search_bar.dart';
import 'package:fitness_day/core/widgets/app_segmented_control.dart';
import 'package:fitness_day/core/widgets/visit_card.dart';
import 'package:fitness_day/core/widgets/app_drawer.dart';
import 'package:fitness_day/core/widgets/loader_hud.dart';
import 'package:fitness_day/core/widgets/network_error_view.dart';
import 'package:fitness_day/core/widgets/top_centered_constrained_box.dart';
import 'package:fitness_day/core/injection/injection_container.dart' as di;
import 'package:fitness_day/features/specialist/visits/presentation/manager/visits_cubit.dart';
import 'package:fitness_day/features/specialist/visits/presentation/manager/visits_state.dart';
import 'visit_details_page.dart';

class VisitsPage extends StatelessWidget {
  const VisitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.getIt<VisitsCubit>()..getVisits(type: 'UPCOMING'),
      child: const _VisitsPageContent(),
    );
  }
}

class _VisitsPageContent extends StatefulWidget {
  const _VisitsPageContent();

  @override
  State<_VisitsPageContent> createState() => _VisitsPageContentState();
}

class _VisitsPageContentState extends State<_VisitsPageContent> {
  int _selectedTabIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<VisitsCubit>().loadMoreVisits();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _getTypeString(int index) {
    return index == 0 ? 'UPCOMING' : 'PREVIOUS';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.profileGradient,
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
                            context.read<VisitsCubit>().getVisits(
                                  type: _getTypeString(_selectedTabIndex),
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
                            'visits.tab_upcoming'.tr(), // index 0
                            'visits.tab_history'.tr(),  // index 1
                          ],
                          selectedIndex: _selectedTabIndex,
                          onItemSelected: (index) {
                            setState(() {
                              _selectedTabIndex = index;
                            });
                            context.read<VisitsCubit>().getVisits(
                                  type: _getTypeString(index),
                                  search: _searchController.text,
                                );
                          },
                        ),
                      ),

                      SizedBox(height: 10.h),

                      // 4. Visit Cards List
                      Expanded(
                        child: BlocBuilder<VisitsCubit, VisitsState>(
                          builder: (context, state) {
                            if (state is VisitsLoading) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (state is VisitsFailure) {
                              return NetworkErrorView(
                                onRetry: () => context.read<VisitsCubit>().getVisits(
                                      type: _getTypeString(_selectedTabIndex),
                                      search: _searchController.text,
                                    ),
                              );
                            } else if (state is VisitsSuccess || state is VisitsLoadingMore) {
                              final visits = state is VisitsSuccess
                                  ? state.visits
                                  : (state as VisitsLoadingMore).visits;

                              if (visits.isEmpty) {
                                return Center(
                                  child: Text(
                                    _selectedTabIndex == 0
                                        ? 'clients_page.no_upcoming_visits'.tr()
                                        : 'clients_page.no_past_visits'.tr(),
                                  ),
                                );
                              }

                              final isUpcoming = _selectedTabIndex == 0;

                              return RefreshIndicator(
                                onRefresh: () => context.read<VisitsCubit>().getVisits(
                                      type: _getTypeString(_selectedTabIndex),
                                      isRefresh: true,
                                      search: _searchController.text,
                                    ),
                                child: ListView.separated(
                                  controller: _scrollController,
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  padding: EdgeInsets.all(20.h),
                                  separatorBuilder: (context, index) => SizedBox(height: 10.h),
                                  itemCount: visits.length + (state is VisitsLoadingMore ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index >= visits.length) {
                                      return Padding(
                                        padding: EdgeInsets.symmetric(vertical: 16.h),
                                        child: const Center(child: CircularProgressIndicator()),
                                      );
                                    }

                                    final visit = visits[index];

                                    String formattedDate = '';
                                    if (visit.weekStart.isNotEmpty) {
                                      final parsed = DateTime.tryParse(visit.weekStart);
                                      if (parsed != null) {
                                        formattedDate = DateFormat('yyyy-MM-dd hh:mm a',
                                                context.locale.languageCode)
                                            .format(parsed.toLocal());
                                      }
                                    }
                                    if (formattedDate.isEmpty) {
                                      formattedDate = visit.weekStart;
                                    }

                                    final timeRem = isUpcoming && index == 0
                                        ? 'visits.in_minutes'.tr(args: ['25'])
                                        : '';

                                    return VisitCard(
                                      timeRemaining: timeRem,
                                      title: visit.name,
                                      subtitle: visit.description,
                                      personName: visit.user?.name ?? '',
                                      visitTime: formattedDate,
                                      location: visit.placement,
                                      buttonText: isUpcoming
                                          ? 'visits.view_visit'.tr()
                                          : 'visits.details'.tr(),
                                      onViewPressed: () {
                                        // If isNew && isStarted, the visit was already started —
                                        // open directly in history/details mode (no Start/Reschedule).
                                        final openAsUpcoming = isUpcoming &&
                                            !(visit.isNew && visit.isStarted);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => VisitDetailsPage(
                                              isUpcoming: openAsUpcoming,
                                              assessmentId: visit.assessmentId,
                                            ),
                                          ),
                                        );
                                      },
                                      iconPath: visit.image.isNotEmpty ? visit.image : SvgIcons.monitor,
                                      isUpcoming: isUpcoming,
                                    );
                                  },
                                ),
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
    );
  }
}
