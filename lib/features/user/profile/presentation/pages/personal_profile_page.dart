import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_shadows.dart';
import 'package:fitness_day/core/widgets/app_back_header.dart';
import 'package:fitness_day/core/widgets/challenge_image_picker.dart';
import 'package:fitness_day/features/user/auth/presentation/manager/user_setup_cubit.dart';
import 'package:fitness_day/features/user/profile/presentation/manager/user_profile_cubit.dart';
import 'package:fitness_day/features/user/profile/presentation/manager/user_profile_state.dart';
import 'package:fitness_day/features/user/profile/presentation/widgets/edit_field_dialog.dart';
import 'package:fitness_day/features/user/profile/presentation/widgets/edit_goal_dialog.dart';

class PersonalProfilePage extends StatefulWidget {
  const PersonalProfilePage({super.key});

  @override
  State<PersonalProfilePage> createState() => _PersonalProfilePageState();
}

class _PersonalProfilePageState extends State<PersonalProfilePage> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<UserProfileCubit>();
    if (cubit.profileData == null) {
      cubit.getUserProfile();
    }
  }

  String _identifierLabel(String typeOfIdentifier) {
    return typeOfIdentifier == 'PHONE'
        ? 'login.phone_hint'.tr()
        : 'profile_page.email'.tr();
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
                child: BlocBuilder<UserProfileCubit, UserProfileState>(
                  builder: (context, state) {
                    final cubit = context.read<UserProfileCubit>();
                    final data = state is UserProfileSuccess ? state.data : cubit.profileData;
                    final isUpdating = state is UserProfileUpdating;

                    final name = data?.fullName ?? '';
                    final identifier = data?.identifier ?? '';
                    final typeOfIdentifier = data?.typeOfIdentifier ?? '';
                    final weight = cubit.lastKnownWeight;
                    final height = cubit.lastKnownHeight;
                    final goalId = cubit.lastKnownGoalId;
                    final goals = context.watch<UserSetupCubit>().goals;
                    final goalName = goals.where((g) => g.id == goalId).firstOrNull?.name;

                    return SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        children: [
                          // Profile Picture
                          Center(
                            child: ChallengeImagePicker(
                              initialImageUrl: data?.avatar,
                              showEditOverlay: true,
                              size: 100.r,
                              onImagePicked: (file) {
                                cubit.updateUserProfile(avatarPath: file.path);
                              },
                            ),
                          ),

                          SizedBox(height: 30.h),

                          if (isUpdating) ...[
                            const CircularProgressIndicator(),
                            SizedBox(height: 16.h),
                          ],

                          // Detail Rows
                          _buildProfileRow(
                            label: 'login.full_name_hint'.tr(),
                            value: name,
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => EditFieldDialog(
                                  title: 'login.full_name_hint'.tr(),
                                  hintText: name,
                                  iconPath: SvgIcons.editName,
                                  onSave: (val) => cubit.updateUserProfile(fullName: val),
                                ),
                              );
                            },
                          ),
                          _buildProfileRow(
                            label: _identifierLabel(typeOfIdentifier),
                            value: identifier,
                            onTap: null,
                          ),
                          _buildProfileRow(
                            label: 'login.weight_hint'.tr(),
                            value: weight != null
                                ? '$weight ${'visit_details.kg'.tr()}'
                                : '',
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => EditFieldDialog(
                                  title: 'login.weight_hint'.tr(),
                                  hintText: weight?.toString() ?? '',
                                  iconPath: SvgIcons.wieght,
                                  keyboardType: TextInputType.number,
                                  onSave: (val) => cubit.updateUserProfile(weight: val),
                                ),
                              );
                            },
                          ),
                          _buildProfileRow(
                            label: 'login.height_hint'.tr(),
                            value: height != null
                                ? '$height ${'visit_details.cm'.tr()}'
                                : '',
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => EditFieldDialog(
                                  title: 'login.height_hint'.tr(),
                                  hintText: height?.toString() ?? '',
                                  iconPath: SvgIcons.height,
                                  keyboardType: TextInputType.number,
                                  onSave: (val) => cubit.updateUserProfile(height: val),
                                ),
                              );
                            },
                          ),
                          _buildProfileRow(
                            label: 'login.goal_hint'.tr(),
                            value: goalName ?? '',
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => EditGoalDialog(
                                  goals: goals,
                                  currentGoalId: goalId,
                                  onSave: (id, _) => cubit.updateUserProfile(goalId: id),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 40.h),
                        ],
                      ),
                    );
                  },
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
    required VoidCallback? onTap,
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
              if (onTap != null) ...[
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
            ],
          ),
        ],
      ),
    );
  }
}
