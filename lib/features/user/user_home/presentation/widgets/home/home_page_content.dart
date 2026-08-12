import 'package:fitness_day/core/cache/app_cache.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/current_weight_card.dart';
import 'package:fitness_day/features/user/user_home/presentation/manager/user_home_cubit.dart';
import 'package:fitness_day/features/user/user_home/presentation/manager/user_home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/stat_cards_row.dart';
import 'package:fitness_day/core/widgets/today_tasks_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/user_app_drawer.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/home_header.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/section_header.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/subscription_banner.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/hero_image.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/categories.dart';
import 'package:fitness_day/core/widgets/task_card.dart';
import 'package:fitness_day/core/entities/task_data.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/articles_section.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/unsubscribed_hero_image.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/features/user/user_home/presentation/screens/hydration_details_screen.dart';
import 'package:fitness_day/features/user/user_home/presentation/screens/steps_details_screen.dart';
import 'package:fitness_day/features/user/market/presentation/widgets/package_details_dialog.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/subscription_packages_grid.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/home_shimmer_loading.dart';
import 'package:fitness_day/core/widgets/home_connectivity_banner.dart';

import 'package:fitness_day/core/widgets/exit_dialog.dart';
import 'package:fitness_day/core/widgets/errors/app_error_view.dart';
import 'package:fitness_day/features/user/user_home/presentation/screens/user_today_tasks_page.dart';
import 'package:fitness_day/features/user/user_home/presentation/screens/articles_list_page.dart';
import 'package:fitness_day/core/widgets/errors/show_app_error.dart';

class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Opens the store's plan dialog for the plan the user is subscribed to.
  /// It loads its own data from `GET /plans/:id`, so only the id is needed.
  void _showSubscribedPlanDetails(BuildContext context, String planId) {
    showDialog(
      context: context,
      barrierColor: AppColors.black.withValues(alpha: 0.6),
      builder: (_) => PackageDetailsDialog(planId: planId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserHomeCubit, UserHomeState>(
      builder: (context, state) {
        if (state is UserHomeLoading) {
          return const Scaffold(
            backgroundColor: AppColors.white,
            body: SafeArea(bottom: false, child: HomeShimmerLoading()),
          );
        }
        if (state is UserHomeLoaded) {
          final isSubscribed = state.isSubscribed;
          final homeData = state.homeData;

          // Extract dynamic values from homeData
          final userName = homeData?.user?['name'] as String? ?? '';
          final userAvatar = homeData?.user?['avatar'] as String? ?? '';
          final subscription = homeData?.subscription;
          final subscriptionName = subscription?.name;
          final subscriptionEndDate = subscription?.endDate;
          final subscribedPlanId = subscription?.planId;
          final currentWeight = homeData?.currentWeight?['value'];
          final weightUnit = homeData?.currentWeight?['unit'] as String? ?? 'kg';
          final weightStatus = homeData?.currentWeight?['status'] as String?;
          final visitsCount = homeData?.visits?['visitsCount'] as int? ?? 0;
          final nextVisitDate = homeData?.visits?['nextVisitDate'] as String?;
          final bannerUrl = homeData?.banners.isNotEmpty == true ? homeData!.banners.first.photo : null;
          final currentActivity = homeData?.dailyTasks?.currentActivity;

          return PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (didPop) return;
          showDialog(
            context: context,
            builder: (context) => const ExitDialog(),
          );
        },
        child: Scaffold(
          backgroundColor: AppColors.white,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(0),
            child: AppBar(
            elevation: 0,
            backgroundColor: AppColors.headerBackground,
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
            ),
          ),
        ),
        endDrawer: UserAppDrawer(isSubscribed: isSubscribed),
        body: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            // Silent: RefreshIndicator draws its own spinner, so dropping the
            // page to the shimmer on top of it just makes the content flash —
            // and wiping a loaded home for a refresh the user can repeat is
            // worse than leaving it up.
            //
            // But silent cannot mean *nothing*: the user pulled, so they are
            // owed an answer. A failure comes back as a return value and is
            // shown over the page instead of replacing it.
            onRefresh: () async {
              final error = await context
                  .read<UserHomeCubit>()
                  .loadHomeData(silent: true);
              if (error != null && context.mounted) {
                showAppError(context, error);
              }
            },
            color: AppColors.primary,
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Header
                HomeHeader(
                  isSubscribed: isSubscribed,
                  userName: userName,
                  userAvatar: userAvatar,
                ),
                // Offline / reconnected banner — slides in below the header
                // and collapses to zero height when the connection is healthy.
                const HomeConnectivityBanner(),
                SizedBox(height: 12.h),

                if (isSubscribed) ...[
                  // 2. Subscription Banner
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: SubscriptionBanner(
                      subscriptionName: subscriptionName,
                      subscriptionEndDate: subscriptionEndDate,
                      // Tapping the banner opens the same plan dialog the
                      // store uses. `GET /plans/:id` reports the active
                      // subscription itself, so the dialog shows the expiry
                      // date and the cancel button rather than "add to cart".
                      onSubscribedTap: subscribedPlanId == null
                          ? null
                          : () => _showSubscribedPlanDetails(
                                context,
                                subscribedPlanId,
                              ),
                    ),
                  ),
                  SizedBox(height: 22.h),

                  // 3. Hero Image
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: HeroImage(imageUrl: bannerUrl),
                  ),
                  SizedBox(height: 20.h),

                  // 4. Categories
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: const Categories(),
                  ),
                  SizedBox(height: 20.h),

                  // 5. Stat Cards
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: StatCardsRow(
                      visitsCount: visitsCount,
                      nextVisitDate: nextVisitDate,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // 6. Current Weight
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: CurrentWeightCard(
                      weight: currentWeight?.toDouble(),
                      unit: weightUnit,
                      status: weightStatus,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // 7. Today's Tasks
                  if (homeData?.dailyTasks != null) ...[
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: SectionHeader(
                        title: 'home.todays_tasks'.tr(),
                        onMorePressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const UserTodayTasksPage(),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: TodayTasksSection(tasks: state.tasks),
                    ),
                    SizedBox(height: 16.h),
                  ],

                  // 8. Activities (Hydration, Walking, Running)
                  if (currentActivity != null)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
                        children: [
                          TaskCard(
                            task: TaskData(
                              imagePath: (currentActivity['image'] == null || 
                                          currentActivity['image'].toString().endsWith('/.png') || 
                                          currentActivity['image'].toString().endsWith('/.jpg')) 
                                          ? SvgIcons.waterBorder 
                                          : currentActivity['image'],
                              isSvgImage: currentActivity['image'] == null || 
                                          currentActivity['image'].toString().endsWith('/.png') || 
                                          currentActivity['image'].toString().endsWith('/.jpg'),
                              // Empty, not the hydration copy: these fall back
                              // for *any* activity, so a walking task with no
                              // description of its own was captioned "staying
                              // hydrated helps improve energy and focus".
                              // Missing text is shown as missing — the today
                              // tasks screen already does this.
                              title: currentActivity['name'] as String? ?? '',
                              time: 'home.hydration_all_day'.tr(),
                              description:
                                  currentActivity['description'] as String? ?? '',
                              extraLabel: '${currentActivity['currentProgress'] ?? 0}',
                              extraUnit: '/ ${currentActivity['goal'] ?? 0} ${currentActivity['unit'] ?? ''}',
                              extraIcon: _activityIcon(currentActivity['activityType'] as String? ?? ''),
                              done: currentActivity['isCompleted'] ?? false,
                              onDetailsPressed: () async {
                                final String activityType =
                                    currentActivity['activityType'] as String? ?? '';
                                final String activityId =
                                    currentActivity['activityId'] as String? ?? '';
                                final String rawAssessmentId =
                                    homeData?.dailyTasks?.assessmentId ?? '';
                                final String assessmentId = rawAssessmentId.isNotEmpty
                                    ? rawAssessmentId
                                    : (getIt<AppCache>().getAssessmentId() ?? '');
                                final int dayNumber =
                                    homeData?.dailyTasks?.dayNumber ?? 1;
                                if (activityType == 'hydration') {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => HydrationDetailsScreen(
                                        assessmentId: assessmentId,
                                        dayNumber: dayNumber,
                                        activityId: activityId,
                                      ),
                                    ),
                                  );
                                } else if (activityType == 'walking' ||
                                    activityType == 'running') {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => StepsDetailsScreen(
                                        type: activityType == 'running'
                                            ? ActivityType.running
                                            : ActivityType.walking,
                                        assessmentId: assessmentId,
                                        dayNumber: dayNumber,
                                        activityId: activityId,
                                      ),
                                    ),
                                  );
                                }
                                // No refetch on the way back: the activity
                                // screens publish every server-confirmed
                                // reading to AppEventBus while they are
                                // open, and UserHomeCubit patches this card
                                // from it. The card is already current by the
                                // time the pop animation finishes.
                              },
                            ),
                          ),
                          SizedBox(height: 16.h),
                        ],
                      ),
                    ),
                  if (currentActivity != null) SizedBox(height: 20.h),

                  // 9. Articles
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: SectionHeader(
                      title: 'home.articles_title'.tr(),
                      onMorePressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ArticlesListPage(articles: state.articles),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Padding(
                    padding: EdgeInsets.only(right: 16.w),
                    child: ArticlesSection(articles: state.articles),
                  ),
                  SizedBox(height: 32.h),
                ] else ...[
                  // Unsubscribed Content
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: SubscriptionBanner(
                      isSubscribed: false,
                      onSubscribeTap: () {
                        _scrollController.animateTo(
                          _scrollController.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 22.h),
                  
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: const UnsubscribedHeroImage(),
                  ),
                  SizedBox(height: 24.h),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(
                      'home.choose_suitable_package'.tr(),
                      style: TextStyleManager.heading3.copyWith(
                        color: AppColors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: SubscriptionPackagesGrid(packages: state.packages),
                  ),
                  SizedBox(height: 32.h),
                ],
              ],
            ),
          ),
        ),
      ),
        ));
        }
        if (state is UserHomeError) {
          return Scaffold(
            backgroundColor: AppColors.white,
            body: AppErrorView(
              error: state.error,
              message: state.message,
              onRetry: () => context.read<UserHomeCubit>().loadHomeData(),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

IconData _activityIcon(String activityType) {
  switch (activityType) {
    case 'hydration':
      return Icons.water_drop_outlined;
    case 'walking':
      return Icons.directions_walk;
    case 'running':
      return Icons.directions_run;
    default:
      return Icons.local_activity_outlined;
  }
}
