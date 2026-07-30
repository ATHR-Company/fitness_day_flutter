import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:fitness_day/core/widgets/action_confirm_dialog.dart';

/// "Are you sure you want to cancel your subscription?" — the app's standard
/// confirmation look ([ActionConfirmDialog]) with the subscription copy.
class CancelSubscriptionDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const CancelSubscriptionDialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return ActionConfirmDialog(
      icon: Icons.close,
      title: 'market.cancel_sub_title'.tr(),
      warning: 'market.cancel_sub_warning'.tr(),
      confirmText: 'market.cancel_sub_confirm'.tr(),
      cancelText: 'market.cancel_sub_back'.tr(),
      onConfirm: onConfirm,
    );
  }
}
