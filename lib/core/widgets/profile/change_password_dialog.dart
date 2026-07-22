import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:fitness_day/core/widgets/app_snack_bar.dart';
import 'package:fitness_day/core/widgets/custom_button.dart';
import 'package:fitness_day/core/widgets/custom_outlined_button.dart';
import 'package:fitness_day/core/widgets/loader.dart';
import 'package:fitness_day/features/user/profile/presentation/manager/user_profile_cubit.dart';
import 'profile_text_field.dart';

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    setState(() => _isLoading = true);
    final result = await context.read<UserProfileCubit>().changePassword(
          oldPassword: _oldPasswordController.text,
          newPassword: _newPasswordController.text,
          newPasswordConfirm: _confirmPasswordController.text,
        );
    if (!mounted) return;
    setState(() => _isLoading = false);

    switch (result) {
      case Success(:final data):
        Navigator.of(context).pop();
        showAppSnackBar(context, text: data, isSuccess: true);
      case FailureResult(:final failure):
        showAppSnackBar(context, text: failure.message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 24.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.lightGreenBackground, AppColors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text('profile.edit_password'.tr(), style: TextStyleManager.heading3),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: AppImage(SvgIcons.cross, color: AppColors.primary, width: 20.r, height: 20.r),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                ProfileTextField(
                  controller: _oldPasswordController,
                  hintText: 'profile.current_password'.tr(),
                  iconPath: SvgIcons.password,
                  isPassword: true,
                ),
                SizedBox(height: 16.h),
                ProfileTextField(
                  controller: _newPasswordController,
                  hintText: 'profile.new_password'.tr(),
                  iconPath: SvgIcons.password,
                  isPassword: true,
                ),
                SizedBox(height: 16.h),
                ProfileTextField(
                  controller: _confirmPasswordController,
                  hintText: 'profile.confirm_new_password'.tr(),
                  iconPath: SvgIcons.password,
                  isPassword: true,
                ),
                SizedBox(height: 32.h),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'profile.save'.tr(),
                        onPressed: _onSave,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: CustomOutlinedButton(
                        text: 'profile.cancel'.tr(),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (_isLoading)
              Positioned.fill(
                child: AbsorbPointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    child: const Center(
                      child: ColorLoader(radius: 16, dotRadius: 4),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
