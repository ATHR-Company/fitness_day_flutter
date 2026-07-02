import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_shadows.dart';
import 'package:fitness_day/core/widgets/app_back_header.dart';
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
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.profileGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: AppBackHeader(
                  title: 'profile.personal_profile'.tr(),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    children: [

                      // Profile Picture
                      Center(
                        child: Column(
                          children: [
                            Center(
                              child: SvgPicture.asset(
                                SvgIcons.profilePhoto,
                                width: 100.r,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                    'profile_page.change_photo'.tr(),
                                    style: TextStyleManager.style9Medium
                                ),
                                SizedBox(width: 7.w),
                                GestureDetector(child: SvgPicture.asset(SvgIcons.editInfo))
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 30.h),

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
                              iconPath: SvgIcons.editName,
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
                              iconPath: SvgIcons.wieght,
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
        ),
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
              SizedBox(width: 12.w),
              GestureDetector(
                onTap: onTap,
                child: SvgPicture.asset(
                  SvgIcons.editInfo,
                  width: 11.r,
                  height: 11.r,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
