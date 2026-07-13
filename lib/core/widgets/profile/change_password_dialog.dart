import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'profile_dialog_base.dart';
import 'profile_text_field.dart';

class ChangePasswordDialog extends StatelessWidget {
  const ChangePasswordDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileDialogBase(
      title: 'profile.edit_password'.tr(),
      onSave: () async {},
      child: Column(
        children: [
          ProfileTextField(
            hintText: 'profile.current_password'.tr(),
            iconPath: SvgIcons.password,
            isPassword: true,
          ),
          SizedBox(height: 16.h),
          ProfileTextField(
            hintText: 'profile.new_password'.tr(),
            iconPath: SvgIcons.password,
            isPassword: true,
          ),
          SizedBox(height: 16.h),
          ProfileTextField(
            hintText: 'profile.confirm_new_password'.tr(),
            iconPath: SvgIcons.password,
            isPassword: true,
          ),
        ],
      ),
    );
  }
}
