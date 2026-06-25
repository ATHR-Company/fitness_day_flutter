import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/shared/widgets/app_back_header.dart';
import 'package:fitness_day/features/shared/widgets/custom_button.dart';
import 'package:fitness_day/features/shared/widgets/selection_bottom_sheet.dart';

class AddActivityPage extends StatefulWidget {
  const AddActivityPage({super.key});

  @override
  State<AddActivityPage> createState() => _AddActivityPageState();
}

class _AddActivityPageState extends State<AddActivityPage> {
  String? _selectedActivityName;

  void _showActivityNameSheet() {
    final items = [
      'add_activity.activity_1'.tr(),
      'add_activity.activity_2'.tr(),
      'add_activity.activity_3'.tr(),
    ];
    showSelectionBottomSheet(
      context: context,
      title: 'add_activity.activity_name'.tr(),
      items: items,
      showSearch: true,
      initialSelectedIndex: _selectedActivityName != null ? items.indexOf(_selectedActivityName!) : 0,
      onConfirm: (index) {
        setState(() {
          _selectedActivityName = items[index];
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.visitsBackgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 20.h),

              // Back Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: AppBackHeader(
                  title: 'add_activity.title'.tr(),
                ),
              ),

              SizedBox(height: 32.h),

              // Content Area
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Activity Name
                      _buildLabel('add_activity.activity_name'.tr()),
                      _buildTextField(
                        hint: _selectedActivityName ?? 'add_activity.activity_name_hint'.tr(),
                        icon: Icons.chevron_left,
                        onTap: _showActivityNameSheet,
                        valueColor: _selectedActivityName != null ? AppColors.black : AppColors.textSecondary.withValues(alpha: 0.5),
                      ),
                      
                      SizedBox(height: 20.h),
                      
                      // Target Goal
                      _buildLabel('add_activity.target_goal'.tr()),
                      _buildTargetGoalField(),

                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),

              // Add Button
              Container(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
                child: CustomButton(
                  text: 'add_activity.add_button'.tr(),
                  color: AppColors.primary, 
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        style: TextStyleManager.heading3.copyWith(
          color: AppColors.black,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildTextField({required String hint, required IconData icon, VoidCallback? onTap, Color? valueColor}) {
    return TextFormField(
      readOnly: onTap != null,
      onTap: onTap,
      textAlign: TextAlign.right,
      style: TextStyleManager.heading3.copyWith(color: AppColors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyleManager.heading3.copyWith(color: valueColor ?? AppColors.textSecondary.withValues(alpha: 0.5)),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        fillColor: AppColors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.divider, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.divider, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.0),
        ),
        suffixIcon: Icon(
          icon,
          color: AppColors.textSecondary.withValues(alpha: 0.5),
          size: 24.sp,
        ),
      ),
    );
  }

  Widget _buildTargetGoalField() {
    return TextFormField(
      textAlign: TextAlign.right,
      style: TextStyleManager.heading3.copyWith(color: AppColors.black),
      decoration: InputDecoration(
        hintText: 'add_activity.target_goal_hint'.tr(),
        hintStyle: TextStyleManager.heading3.copyWith(color: AppColors.textSecondary.withValues(alpha: 0.5)),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h), 
        fillColor: AppColors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.divider, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.divider, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.0),
        ),
        suffixIcon: IntrinsicHeight(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(4.w),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.backgroundTint,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: AppColors.divider.withValues(alpha: 0.3), width: 1),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  child: Row(
                    children: [
                      Text(
                        'add_activity.step'.tr(),
                        style: TextStyleManager.heading3.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.primary,
                        size: 20.sp,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
