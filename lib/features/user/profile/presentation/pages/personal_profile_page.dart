import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_shadows.dart';
import 'package:fitness_day/features/user/profile/presentation/widgets/edit_field_dialog.dart';
import 'package:fitness_day/features/user/profile/presentation/widgets/edit_phone_dialog.dart';
import 'package:fitness_day/features/user/profile/presentation/widgets/edit_goal_dialog.dart';

class PersonalProfilePage extends StatefulWidget {
  const PersonalProfilePage({super.key});

  @override
  State<PersonalProfilePage> createState() => _PersonalProfilePageState();
}

class _PersonalProfilePageState extends State<PersonalProfilePage> {
  // Mock data representing the profile values
  String _name = 'رنا محمد';
  String _email = 'rana mohamed@gmail.com';
  String _phone = '99567890211';
  String _weight = '57.8';
  String _height = '167';
  String _goal = 'login.goal_gain'; // Locales: زيادة الوزن

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.headerBackground,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'profile.personal_profile'.tr(),
          style: TextStyleManager.heading2.copyWith(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Header background arch
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 60.h,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.headerBackground,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(100),
                  bottomRight: Radius.circular(100),
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  SizedBox(height: 24.h),

                  // Profile Picture
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 100.r,
                              height: 100.r,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  SvgIcons.profile,
                                  width: 50.r,
                                  colorFilter: const ColorFilter.mode(
                                    AppColors.primary,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              child: Container(
                                padding: EdgeInsets.all(4.r),
                                decoration: const BoxDecoration(
                                  color: AppColors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Container(
                                  padding: EdgeInsets.all(6.r),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.edit,
                                    color: AppColors.white,
                                    size: 14.r,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'profile_page.change_photo'.tr(), // "تغيير الصورة الشخصية"
                            style: TextStyleManager.style11Medium.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Detail Rows
                  _buildProfileRow(
                    label: 'login.full_name_hint'.tr(), // "الاسم"
                    value: _name,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => EditFieldDialog(
                          title: 'login.full_name_hint'.tr(),
                          hintText: _name,
                          iconPath: SvgIcons.person,
                          onSave: (val) => setState(() => _name = val),
                        ),
                      );
                    },
                  ),
                  _buildProfileRow(
                    label: 'profile_page.email'.tr(), // "البريد الإلكتروني"
                    value: _email,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => EditFieldDialog(
                          title: 'profile_page.email'.tr(),
                          hintText: _email,
                          iconPath: SvgIcons.email,
                          onSave: (val) => setState(() => _email = val),
                        ),
                      );
                    },
                  ),
                  _buildProfileRow(
                    label: 'login.phone_hint'.tr(), // "رقم الجوال"
                    value: _phone,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => EditPhoneDialog(
                          initialPhone: _phone,
                          onSave: (val) => setState(() => _phone = val),
                        ),
                      );
                    },
                  ),
                  _buildProfileRow(
                    label: 'login.weight_hint'.tr(), // "الوزن"
                    value: '$_weight ${'visit_details.kg'.tr()}',
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => EditFieldDialog(
                          title: 'login.weight_hint'.tr(),
                          hintText: _weight,
                          iconPath: SvgIcons.weight,
                          keyboardType: TextInputType.number,
                          onSave: (val) => setState(() => _weight = val),
                        ),
                      );
                    },
                  ),
                  _buildProfileRow(
                    label: 'login.height_hint'.tr(), // "الطول"
                    value: '$_height ${'visit_details.cm'.tr()}',
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => EditFieldDialog(
                          title: 'login.height_hint'.tr(),
                          hintText: _height,
                          iconPath: SvgIcons.height,
                          keyboardType: TextInputType.number,
                          onSave: (val) => setState(() => _height = val),
                        ),
                      );
                    },
                  ),
                  _buildProfileRow(
                    label: 'login.goal_hint'.tr(), // "الهدف من التطبيق"
                    value: _goal.tr(),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => EditGoalDialog(
                          currentGoal: _goal,
                          onSave: (val) => setState(() => _goal = val),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Row Item Builder
  Widget _buildProfileRow({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.dividerLight,
          width: 0.5.w,
        ),
        boxShadow: AppShadows.profileItemShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Right visual side: label
          Text(
            label,
            style: TextStyleManager.style11Medium,
          ),
          // Left visual side: value + edit button (RTL layout)
          Row(
            children: [
              Text(
                value,
                style: TextStyleManager.style11Medium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 5.w),
              GestureDetector(
                onTap: onTap,
                child: Icon(
                  Icons.edit,
                  color: AppColors.primary,
                  size: 15.r,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
