
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/widgets/exit_dialog.dart';
import 'package:fitness_day/features/user/market/presentation/widgets/pending_payment_watcher.dart';
import 'package:fitness_day/features/user/user_home/presentation/manager/user_home_cubit.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/home/home_page_content.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/home/daily_check_in_dialog.dart';

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
    _maybeShowDailyCheckIn();
  }

  /// Pops the daily check-in dialog when the server says today's reward is
  /// still unclaimed. The "once a day" decision belongs to the backend — the
  /// cycle rolls over at 00:00 UTC and is recomputed on every request, so it is
  /// never inferred from a date stored on the device.
  Future<void> _maybeShowDailyCheckIn() async {
    final bool show = await shouldShowDailyCheckIn();
    if (!show || !mounted) return;
    // After the first frame, so the tree is fully mounted and context is usable.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) showDailyCheckInDialog(context);
    });
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
      // Home is the bottom of the stack, so back here means leaving the app.
      // Confirm first rather than dropping the user out on a stray gesture —
      // same treatment as the specialist home.
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          showDialog(
            context: context,
            builder: (context) => const ExitDialog(),
          );
        },
        // Home is the landing screen, so it is where a payment interrupted by
        // the app being killed gets confirmed and reported.
        child: const PendingPaymentWatcher(child: HomePageContent()),
      ),
    );
  }
}

