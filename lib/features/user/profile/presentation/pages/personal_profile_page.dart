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
import 'package:fitness_day/core/widgets/loader.dart';
import 'package:fitness_day/core/utils/decimal_input_formatter.dart';
import 'package:fitness_day/core/utils/measurement.dart';
import 'package:fitness_day/core/utils/validators.dart';
import 'package:fitness_day/features/user/auth/presentation/manager/user_setup_cubit.dart';
import 'package:fitness_day/features/user/profile/presentation/manager/user_profile_cubit.dart';
import 'package:fitness_day/features/user/profile/presentation/manager/user_profile_state.dart';
import 'package:fitness_day/features/user/profile/presentation/widgets/edit_field_dialog.dart';
import 'package:fitness_day/features/user/profile/presentation/widgets/edit_goal_dialog.dart';
import 'package:fitness_day/core/widgets/errors/show_app_error.dart';

class PersonalProfilePage extends StatefulWidget {
  const PersonalProfilePage({super.key});

  @override
  State<PersonalProfilePage> createState() => _PersonalProfilePageState();
}

class _PersonalProfilePageState extends State<PersonalProfilePage> {
  bool _isAvatarUploading = false;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<UserProfileCubit>();
    if (cubit.profileData == null) {
      cubit.getUserProfile();
    }
    // Defensive fallback: lookups are normally already loading by app
    // startup (see fitness_day.dart), but if this is somehow the first
    // thing to need them (e.g. a slow connection), kick off the fetch
    // rather than leaving the goal row blank for the rest of the session.
    final setupCubit = context.read<UserSetupCubit>();
    if (setupCubit.goals.isEmpty) {
      setupCubit.fetchLookups();
    }
  }

  /// The server's rejection message for the edit that just ran, or `null` when
  /// it succeeded. Handed to each [EditFieldDialog] so the reason lands under
  /// the field being edited.
  String? _updateError(UserProfileCubit cubit) {
    final state = cubit.state;
    return state is UserProfileUpdateFailure ? state.message : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocListener<UserProfileCubit, UserProfileState>(
        listenWhen: (previous, current) => current is UserProfileUpdateFailure,
        listener: (context, state) {
          if (state is! UserProfileUpdateFailure) return;
          // An open dialog shows the message under its own field, so the
          // full-width banner would be a second copy of it — on top of the
          // screen the user has already left. This only fires for edits with
          // no dialog behind them, like the avatar upload.
          if (ModalRoute.of(context)?.isCurrent != true) return;
          showAppError(context, state.error, message: state.message);
        },
        child: Container(
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

                    final name = data?.fullName ?? '';
                    final weight = cubit.lastKnownWeight;
                    final height = cubit.lastKnownHeight;
                    final goalId = cubit.lastKnownGoalId;
                    final goals = context.watch<UserSetupCubit>().goals;
                    // GET /users/my-profile returns goal as a display name, not an ID.
                    // We try matching by ID first (set after a successful update),
                    // then fall back to the raw name string from the server.
                    final goalName = goals.where((g) => g.id == goalId).firstOrNull?.name
                        ?? cubit.lastKnownGoalName;

                    return SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        children: [
                          // Profile Picture
                          Center(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                ChallengeImagePicker(
                                  initialImageUrl: data?.avatar,
                                  showEditOverlay: true,
                                  size: 100.r,
                                  onImagePicked: (file) async {
                                    setState(() => _isAvatarUploading = true);
                                    await cubit.updateUserProfile(avatarPath: file.path);
                                    if (mounted) setState(() => _isAvatarUploading = false);
                                  },
                                ),
                                if (_isAvatarUploading)
                                  Container(
                                    width: 100.r,
                                    height: 100.r,
                                    decoration: BoxDecoration(
                                      color: AppColors.black.withValues(alpha: 0.35),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const ColorLoader(radius: 14, dotRadius: 4),
                                  ),
                              ],
                            ),
                          ),

                          SizedBox(height: 30.h),

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
                                  maxLength: 30,
                                  nameOnly: true,
                                  validator: AppValidators.personName,
                                  normalize: (val) => val.trim(),
                                  errorAfterSave: () => _updateError(cubit),
                                  onSave: (val) =>
                                      cubit.updateUserProfile(fullName: val),
                                ),
                              );
                            },
                          ),
                          _buildProfileRow(
                            label: 'login.weight_hint'.tr(),
                            value: weight != null
                                ? Measurement.withUnit(
                                    weight, 'visit_details.kg'.tr())
                                : 'profile_not_set'.tr(),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => EditFieldDialog(
                                  title: 'login.weight_hint'.tr(),
                                  hintText: weight != null
                                      ? Measurement.format(weight)
                                      : '',
                                  iconPath: SvgIcons.wieght,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  inputFormatters: [DecimalInputFormatter()],
                                  validator: AppValidators.weight,
                                  normalize: (val) =>
                                      Measurement.normalize(val) ?? val,
                                  errorAfterSave: () => _updateError(cubit),
                                  onSave: (val) =>
                                      cubit.updateUserProfile(weight: val),
                                ),
                              );
                            },
                          ),
                          _buildProfileRow(
                            label: 'login.height_hint'.tr(),
                            value: height != null
                                ? Measurement.withUnit(
                                    height, 'visit_details.cm'.tr())
                                : 'profile_not_set'.tr(),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => EditFieldDialog(
                                  title: 'login.height_hint'.tr(),
                                  hintText: height != null
                                      ? Measurement.format(height)
                                      : '',
                                  iconPath: SvgIcons.height,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  inputFormatters: [DecimalInputFormatter()],
                                  validator: AppValidators.height,
                                  normalize: (val) =>
                                      Measurement.normalize(val) ?? val,
                                  errorAfterSave: () => _updateError(cubit),
                                  onSave: (val) =>
                                      cubit.updateUserProfile(height: val),
                                ),
                              );
                            },
                          ),
                          _buildProfileRow(
                            label: 'login.goal_hint'.tr(),
                            value: goalName ?? 'profile_not_set'.tr(),
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
      ),
    );
  }

  // Row Item Builder
  Widget _buildProfileRow({
    required String label,
    required String value,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
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
          children: [
            // Right visual side: label
            Text(
              label,
              style: TextStyleManager.style11Medium,
            ),
            SizedBox(width: 12.w),
            // Left visual side: value + edit button (RTL layout).
            // The value takes the leftover width and ellipsises — a 30-char
            // name used to push the row past the card and paint an overflow
            // stripe over it.
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: TextStyleManager.style11Medium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (onTap != null) ...[
                    SizedBox(width: 12.w),
                    AppImage(
                      SvgIcons.editInfo,
                      width: 11.r,
                      height: 11.r,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
