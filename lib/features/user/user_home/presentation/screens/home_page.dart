
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
import '../../../../../core/theme/app_colors.dart';
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
import '../../../../../core/constant/app_assets.dart';
import 'hydration_details_screen.dart';
import 'steps_details_screen.dart';
import 'package:fitness_day/features/user/market/presentation/widgets/package_details_dialog.dart';
import 'package:fitness_day/features/user/market/presentation/widgets/pending_payment_watcher.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/subscription_packages_grid.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/home_shimmer_loading.dart';

import 'package:fitness_day/core/widgets/exit_dialog.dart';
import 'package:fitness_day/core/widgets/network_error_view.dart';
import 'user_today_tasks_page.dart';
import 'articles_list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final UserHomeCubit _cubit;
  Locale? _lastLocale;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<UserHomeCubit>()..loadHomeData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentLocale = context.locale;
    if (_lastLocale != null && _lastLocale != currentLocale) {
      _cubit.loadHomeData();
    }
    _lastLocale = currentLocale;
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      // Home is the landing screen, so it is where a payment interrupted by
      // the app being killed gets confirmed and reported.
      child: const PendingPaymentWatcher(child: _HomePageContent()),
    );
  }
}

class _HomePageContent extends StatelessWidget {
  const _HomePageContent();

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
            body: SafeArea(child: HomeShimmerLoading()),
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
          child: RefreshIndicator(
            onRefresh: () => context.read<UserHomeCubit>().loadHomeData(),
            color: AppColors.primary,
            child: SingleChildScrollView(
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
                              title: currentActivity['name'] ?? 'home.hydration_title'.tr(),
                              time: 'home.hydration_all_day'.tr(),
                              description: currentActivity['description'] ?? 'home.hydration_desc'.tr(),
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
                                } else {
                                  return;
                                }
                                // The activity screens sync progress while they
                                // are open, so the card behind them is stale by
                                // the time the user comes back.
                                if (!context.mounted) return;
                                context.read<UserHomeCubit>().loadHomeData();
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
                    child: const SubscriptionBanner(isSubscribed: false),
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
            body: NetworkErrorView(
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
