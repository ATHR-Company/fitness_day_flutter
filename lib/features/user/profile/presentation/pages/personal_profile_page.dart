import 'package:flutter/material.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_shadows.dart';
import 'package:fitness_day/core/widgets/app_back_header.dart';
import 'package:fitness_day/features/user/profile/presentation/widgets/edit_field_dialog.dart';
import 'package:fitness_day/features/user/profile/presentation/widgets/edit_phone_dialog.dart';
import 'package:fitness_day/features/user/profile/presentation/widgets/edit_goal_dialog.dart';
import 'package:fitness_day/core/cache/app_cache.dart';
import 'package:fitness_day/core/injection/injection_container.dart';

class PersonalProfilePage extends StatefulWidget {
  const PersonalProfilePage({super.key});

  @override
  State<PersonalProfilePage> createState() => _PersonalProfilePageState();
}

class _PersonalProfilePageState extends State<PersonalProfilePage> {
  late String _name;
  late String _email;
  late String _phone;
  late String _weight;
  late String _height;
  late String _goal;

  @override
  void initState() {
    super.initState();
    final user = getIt<AppCache>().getUser();
    _name = user.name;
    _email = user.email;
    _phone = user.phone;
    _weight = user.weight?.toString() ?? '';
    _height = user.height?.toString() ?? '';
    _goal = user.goal ?? 'login.goal_gain';
  }

  void _updateCache(String field, String val) {
    setState(() {
      if (field == 'name') _name = val;
      if (field == 'email') _email = val;
      if (field == 'phone') _phone = val;
      if (field == 'weight') _weight = val;
      if (field == 'height') _height = val;
      if (field == 'goal') _goal = val;
    });

    final user = getIt<AppCache>().getUser();
    final updated = user.copyWith(
      name: _name,
      email: _email,
      phone: _phone,
      weight: double.tryParse(_weight),
      height: double.tryParse(_height),
      goal: _goal,
    );
    getIt<AppCache>().saveUser(updated);
  }

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
                              child: AppImage(
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
                                GestureDetector(child: AppImage(SvgIcons.editInfo))
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
                              onSave: (val) => _updateCache('name', val),
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
                              onSave: (val) => _updateCache('email', val),
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
                              onSave: (val) => _updateCache('phone', val),
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
                              onSave: (val) => _updateCache('weight', val),
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
                              onSave: (val) => _updateCache('height', val),
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
                              onSave: (val) => _updateCache('goal', val),
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
                child: AppImage(
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
