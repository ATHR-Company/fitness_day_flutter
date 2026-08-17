import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/widgets/confirm_dialog.dart';

/// Confirms leaving a challenge, returning true when the user goes through
/// with it.
///
/// Both entry points — the details sheet and the active screen's ⋮ menu — ask
/// the same question, and both used to build their own bare Material
/// `AlertDialog`. That skipped the app's dialog chrome entirely, so a
/// destructive action was the one dialog in the app with no icon, no rounded
/// card and plain text-button actions.
Future<bool> confirmLeaveChallenge(BuildContext context) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    barrierColor: AppColors.black.withValues(alpha: 0.5),
    builder: (_) => ConfirmDialog(
      icon: Icons.logout_rounded,
      title: 'challenges.leave_title'.tr(),
      subtitle: 'challenges.leave_message'.tr(),
      confirmText: 'challenges.btn_leave'.tr(),
      cancelText: 'profile.cancel'.tr(),
    ),
  );
  return confirmed ?? false;
}
