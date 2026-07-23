import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/widgets/confirm_dialog.dart';

class ExitDialog extends StatelessWidget {
  const ExitDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return ConfirmDialog(
      icon: Icons.exit_to_app_rounded,
      title: 'shared_exit_confirm_title'.tr(),
      subtitle: 'shpared_exit_confirm_subtitle'.tr(),
      confirmText: 'shared_exit_button'.tr(),
      cancelText: 'shared_btn_cancel'.tr(),
      accentColor: AppColors.error,
      onConfirm: () => SystemNavigator.pop(),
    );
  }
}
