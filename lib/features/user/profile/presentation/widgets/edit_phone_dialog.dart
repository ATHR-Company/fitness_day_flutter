import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/widgets/profile/profile_dialog_base.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'dart:ui' as ui;

class EditPhoneDialog extends StatefulWidget {
  final String initialPhone;
  final Function(String) onSave;

  const EditPhoneDialog({
    super.key,
    required this.initialPhone,
    required this.onSave,
  });

  @override
  State<EditPhoneDialog> createState() => _EditPhoneDialogState();
}

class _EditPhoneDialogState extends State<EditPhoneDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialPhone);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProfileDialogBase(
      title: 'login.phone_hint'.tr(),
      onSave: () async => widget.onSave(_controller.text),
      child: Container(
        height: 56.h,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2), width: 1),
        ),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  const Text('🇸🇦', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 8.w),
                  Text(
                    '+966',
                    style: TextStyleManager.style11Medium.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 24.h,
              width: 1.5.w,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                textAlign: TextAlign.right,
                keyboardType: TextInputType.phone,
                textDirection: ui.TextDirection.ltr,
                decoration: InputDecoration(
                  hintText: 'login.phone_hint'.tr(),
                  hintStyle: TextStyleManager.style11Medium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
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
