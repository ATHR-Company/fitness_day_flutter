import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/widgets/app_snack_bar.dart';
import 'package:fitness_day/features/user/market/presentation/manager/cart_cubit.dart';
import 'package:fitness_day/features/user/market/presentation/manager/payment_cubit.dart';
import 'package:fitness_day/features/user/profile/presentation/manager/user_profile_cubit.dart';

/// Finishes a payment this device started but never saw resolve — the case
/// where the app was killed while the buyer was on Paymob's page.
///
/// Wrap a landing screen with it. It is silent unless there is something to
/// resume, and it never blocks the UI: the confirmation runs in the
/// background and only reports the outcome.
class PendingPaymentWatcher extends StatelessWidget {
  final Widget child;

  const PendingPaymentWatcher({super.key, required this.child});

  void _onState(BuildContext context, PaymentState state) {
    switch (state) {
      case PaymentCompleted():
        // The backend already applied everything; just pull the app in line.
        getIt<CartCubit>().loadCart();
        getIt<CartCubit>().loadCounters();
        getIt<UserProfileCubit>().getUserProfile();
        showAppSnackBar(
          context,
          text: 'market.payment_completed_late'.tr(),
          isSuccess: true,
        );

      case PaymentFailed(:final message):
        showAppSnackBar(
          context,
          text: message.startsWith('market.') ? message.tr() : message,
          isError: true,
        );

      // Still unresolved, or unresolvable. Neither is worth interrupting an
      // app launch for — the backend finishes pending payments on its own and
      // a stale marker has already been dropped by the cubit.
      case PaymentAwaitingConfirmation():
      case PaymentNotCompleted():
      case PaymentError():
      case PaymentInitial():
      case PaymentInitiating():
      case PaymentConfirming():
      case PaymentWebviewReady():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PaymentCubit>()..resumePendingPayment(),
      child: BlocListener<PaymentCubit, PaymentState>(
        listener: _onState,
        child: child,
      ),
    );
  }
}
