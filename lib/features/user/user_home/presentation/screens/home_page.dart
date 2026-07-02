
import 'dart:ui' as ui;
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
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../core/constant/app_assets.dart';
import 'hydration_details_screen.dart';
import 'steps_details_screen.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/subscription_packages_grid.dart';

import 'package:fitness_day/core/widgets/exit_dialog.dart';
import 'user_today_tasks_page.dart';
import 'articles_list_page.dart';

class HomePage extends StatelessWidget {
  final bool isSubscribed;

  const HomePage({super.key, this.isSubscribed = true});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserHomeCubit()..loadHomeData(isSubscribed: isSubscribed),
      child: _HomePageContent(),
    );
  }
}

class _HomePageContent extends StatelessWidget {
  const _HomePageContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserHomeCubit, UserHomeState>(
      builder: (context, state) {
        if (state is UserHomeLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (state is UserHomeLoaded) {
          final isSubscribed = state.isSubscribed;
          return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: PopScope(
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
              statusBarBrightness: Brightness.dark,
            ),
          ),
        ),
        endDrawer: UserAppDrawer(isSubscribed: isSubscribed),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Header
                HomeHeader(isSubscribed: isSubscribed),
                SizedBox(height: 12.h),

                if (isSubscribed) ...[
                  // 2. Subscription Banner
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: const SubscriptionBanner(),
                  ),
                  SizedBox(height: 22.h),

                  // 3. Hero Image
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: const HeroImage(),
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
                    child: const StatCardsRow(),
                  ),
                  SizedBox(height: 16.h),

                  // 6. Current Weight
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: const CurrentWeightCard(),
                  ),
                  SizedBox(height: 16.h),

                  // 7. Today's Tasks
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

                  // 8. Activities (Hydration, Walking, Running)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      children: [
                        TaskCard(
                          task: TaskData(
                            imagePath: SvgIcons.waterBorder,
                            isSvgImage: true,
                            title: 'home.hydration_title'.tr(),
                            time: 'home.hydration_all_day'.tr(),
                            description: 'home.hydration_desc'.tr(),
                            extraLabel: '2.50 / 2.50',
                            extraUnit: 'home.water_unit'.tr(),
                            extraIcon: null,
                            done: true,
                            onDetailsPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HydrationDetailsScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      
                      
                        SizedBox(height: 16.h),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),

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
        ),
      );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
