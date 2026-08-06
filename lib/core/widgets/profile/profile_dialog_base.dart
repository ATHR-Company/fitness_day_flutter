import 'package:flutter/material.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/custom_outlined_button.dart';
import 'package:fitness_day/core/widgets/custom_button.dart';
import 'package:fitness_day/core/widgets/loader.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/constant/app_assets.dart';

class ProfileDialogBase extends StatefulWidget {
  final String title;
  final Widget child;
  final Future<void> Function() onSave;

  /// Runs before [onSave]. Returning `false` aborts the save and leaves the
  /// dialog open so the caller can show its own inline error — without this
  /// the dialog pops on every tap and an invalid value goes to the server.
  final bool Function()? validate;

  const ProfileDialogBase({
    super.key,
    required this.title,
    required this.child,
    required this.onSave,
    this.validate,
  });

  @override
  State<ProfileDialogBase> createState() => _ProfileDialogBaseState();
}

class _ProfileDialogBaseState extends State<ProfileDialogBase> {
  bool _isLoading = false;

  Future<void> _onSavePressed() async {
    if (widget.validate != null && !widget.validate!()) return;
    setState(() => _isLoading = true);

    // [onSave] rejects a save by throwing. That was already the contract, but
    // nothing caught it: the exception escaped as an unhandled async error,
    // _isLoading was never cleared, and the dialog sat behind a spinner
    // forever with no way out but the close button.
    //
    // The thrown object is deliberately not shown here — whoever threw it has
    // already put the reason in front of the user, under the field it belongs
    // to.
    var saved = false;
    try {
      await widget.onSave();
      saved = true;
    } catch (e) {
      debugPrint('[ProfileDialogBase] save rejected: $e');
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
    if (saved) Navigator.of(context).pop();
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
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: TextStyleManager.heading3,
                      ),
                    ),
                    GestureDetector(
                      onTap: _isLoading ? null : () => Navigator.of(context).pop(),
                      child: AppImage(
                        SvgIcons.cross,
                        color: AppColors.primary,
                        width: 20.r,
                        height: 20.r,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                // Content
                widget.child,

                SizedBox(height: 32.h),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'profile.save'.tr(),
                        onPressed: _onSavePressed,
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

            // Loading overlay — constrained to the dialog card only.
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
