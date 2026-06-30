import 'package:fitness_day/core/routes/user_routes/app_routes.dart';
import 'dart:ui' as ui;
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/current_weight_card.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/stat_cards_row.dart';
import 'package:fitness_day/features/shared/widgets/today_tasks_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../core/theme/app_colors.dart';
import '../widgets/user_app_drawer.dart';
import '../widgets/home_header.dart';
import '../widgets/section_header.dart';
import '../widgets/subscription_banner.dart';
import '../widgets/hero_image.dart';
import '../widgets/categories.dart';
import '../widgets/activity_progress_card.dart';
import '../widgets/articles_section.dart';
import '../widgets/unsubscribed_hero_image.dart';
import '../widgets/subscription_package_card.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../core/constant/app_assets.dart';
import 'hydration_details_screen.dart';
import '../widgets/subscription_packages_grid.dart';

import '../../../../shared/widgets/exit_dialog.dart';
import 'user_today_tasks_page.dart';
import 'articles_list_page.dart';

class HomePage extends StatelessWidget {
  final bool isSubscribed;

  const HomePage({super.key, this.isSubscribed = true});

  // ── Sample data ─────────────────────────────────────────────────────────────
  static const List<SubscriptionPackageData> _packages = [
    SubscriptionPackageData(
      imageUrl: 'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=400',
      name: 'باقة القمة',
      currentPrice: 2999,
      oldPrice: 5000,
      isFavorite: true,
    ),
    SubscriptionPackageData(
      imageUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400',
      name: 'كورس الشد والتنحيف',
      currentPrice: 1994,
      oldPrice: 4000,
      isFavorite: true,
    ),
    SubscriptionPackageData(
      imageUrl: 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=400',
      name: 'باقة صحي',
      currentPrice: 3500,
      oldPrice: 5000,
      isFavorite: true,
    ),
    SubscriptionPackageData(
      imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
      name: 'باقة تميز',
      currentPrice: 3950,
      oldPrice: 5000,
      isFavorite: false,
    ),
    SubscriptionPackageData(
      imageUrl: 'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?w=400',
      name: 'باقة الهدف',
      currentPrice: 1800,
      oldPrice: 5000,
      isFavorite: false,
    ),
    SubscriptionPackageData(
      imageUrl: 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=400',
      name: 'باقة القمة',
      currentPrice: 2750,
      oldPrice: 5000,
      isFavorite: false,
    ),
  ];



  static const List<TaskData> _tasks = [
    TaskData(
      imagePath:
          'https://images.unsplash.com/photo-1517673132405-a56a62b18caf?w=200',
      title: 'وجبة الافطار',
      description: 'شوفان بالحليب مع مكسرات وعسل',
      time: '8:00 صباحاً',
      extraLabel: '350',
      extraUnit: 'كالورى',
      extraIcon: Icons.local_fire_department,
      done: true,
      route: UserAppRoutes.mealDetails,
    ),
    TaskData(
      imagePath:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=200',
      title: 'تمرين البلانك',
      description:
          'تمرين البلانك يقوى عضلات البطن ويحسن الاستقرار العام للجسم.',
      time: '8:00 صباحاً',
      extraLabel: '1',
      extraUnit: '3',
      extraIcon: null,
      done: false,
    ),
  ];

  static const List<ArticleData> _articles = [
    ArticleData(
      imageUrl:
          'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=400',
      date: '15/2/2026',
      views: 1500,
      title: 'اكتشف 5 أفكار وجبات خفيفة قبل التمرين ..........',
      body:
          'اكتشف 5 أفكار وجبات خفيفة قبل التمرين تساعدك على زيادة الطاقة وتحسين الأداء: موز مع زبدة الفول السوداني- كوب زبادي مع عسل وفواكه -حفنة مكسرات مشكلة - شرائح تفاح.....',
    ),
    ArticleData(
      imageUrl:
          'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=400',
      date: '10/2/2026',
      views: 980,
      title: 'أهمية النوم الجيد لبناء العضلات ..........',
      body:
          'النوم الجيد ضروري لعملية بناء العضلات وتعافيها بعد التمرين. تأكد من الحصول على 7-9 ساعات يومياً لتحقيق أفضل النتائج.',
    ),
    ArticleData(
      imageUrl:
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',
      date: '5/2/2026',
      views: 2300,
      title: 'مشروبات طبيعية قبل التمرين لزيادة النشاط والتركيز',
      body:
          'تعرف على أفضل المشروبات الطبيعية التي تساعدك على زيادة طاقتك وتركيزك قبل التمرين بدون مكملات صناعية.',
    ),
    ArticleData(
      imageUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
      date: '1/2/2026',
      views: 1750,
      title: 'أفضل تمارين الإحماء قبل رفع الأثقال',
      body:
          'الإحماء الصحيح يقلل من خطر الإصابات ويحسن أدائك في التمرين. تعرف على أفضل تمارين الإحماء الديناميكية.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
                    child: TodayTasksSection(tasks: _tasks),
                  ),
                  SizedBox(height: 16.h),

                  // 8. Activities (Hydration, Walking, Running)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      children: [
                        ActivityProgressCard(
                          title: 'home.hydration_title'.tr(),
                          time: 'home.hydration_all_day'.tr(),
                          description: 'home.hydration_desc'.tr(),
                          icon: SvgPicture.asset(SvgIcons.waterBorder, fit: BoxFit.contain),
                          current: 2.50,
                          target: 2.50,
                          unit: 'home.water_unit'.tr(),
                          isCompleted: true,
                          onDetailsPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HydrationDetailsScreen(),
                              ),
                            );
                          },
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
                            builder: (_) => ArticlesListPage(articles: _articles),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Padding(
                    padding: EdgeInsets.only(right: 16.w),
                    child: ArticlesSection(articles: _articles),
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
                    child: SubscriptionPackagesGrid(packages: _packages),
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
}
