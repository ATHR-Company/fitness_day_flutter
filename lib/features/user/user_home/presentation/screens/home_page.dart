
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/features/user/market/presentation/widgets/pending_payment_watcher.dart';
import 'package:fitness_day/features/user/user_home/presentation/manager/user_home_cubit.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/home/home_page_content.dart';

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
      child: const PendingPaymentWatcher(child: HomePageContent()),
    );
  }
}

