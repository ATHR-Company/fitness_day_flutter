import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:fitness_day/features/user/user_home/presentation/manager/user_home_state.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/subscription_package_card.dart';
import 'package:fitness_day/core/widgets/today_tasks_section.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/articles_section.dart';
import 'package:fitness_day/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

class UserHomeCubit extends Cubit<UserHomeState> {
  UserHomeCubit() : super(UserHomeLoading());

  void loadHomeData({bool isSubscribed = true}) {
    emit(UserHomeLoading());

    // Dummy data replacement
    final packages = [
      SubscriptionPackageData(
        imageUrl: 'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=400',
        name: LocaleKeys.home_home_package_1.tr(),
        currentPrice: 2999,
        oldPrice: 5000,
        isFavorite: true,
      ),
      SubscriptionPackageData(
        imageUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400',
        name: LocaleKeys.home_home_package_2.tr(),
        currentPrice: 1994,
        oldPrice: 4000,
        isFavorite: true,
      ),
    ];

    final tasks = [
      TaskData(
        imagePath: 'https://images.unsplash.com/photo-1517673132405-a56a62b18caf?w=200',
        title: LocaleKeys.home_home_task_1_title.tr(),
        description: LocaleKeys.home_home_task_1_desc.tr(),
        time: LocaleKeys.home_home_task_1_time.tr(),
        extraLabel: '350',
        extraUnit: LocaleKeys.home_home_calories_unit.tr(),
        extraIcon: Icons.local_fire_department,
        done: true,
        route: '/meal_details',
      ),
      TaskData(
        imagePath: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=200',
        title: LocaleKeys.home_home_task_2_title.tr(),
        description: LocaleKeys.home_home_task_2_desc.tr(),
        time: LocaleKeys.home_home_task_2_time.tr(),
        extraLabel: '1',
        extraUnit: '3',
        extraIcon: null,
        done: false,
      ),
    ];

    final articles = [
      ArticleData(
        imageUrl: 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=400',
        date: '15/2/2026',
        views: 1500,
        title: LocaleKeys.home_home_article_1_title.tr(),
        body: LocaleKeys.home_home_article_1_desc.tr(),
      ),
      ArticleData(
        imageUrl: 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=400',
        date: '10/2/2026',
        views: 980,
        title: LocaleKeys.home_home_article_2_title.tr(),
        body: LocaleKeys.home_home_article_2_desc.tr(),
      ),
    ];

    emit(UserHomeLoaded(
      packages: packages,
      tasks: tasks,
      articles: articles,
      isSubscribed: isSubscribed,
    ));
  }
}
