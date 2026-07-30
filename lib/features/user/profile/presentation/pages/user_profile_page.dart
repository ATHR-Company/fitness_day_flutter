import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/theme/app_shadows.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/widgets/profile/language_dialog.dart';
import 'package:fitness_day/core/widgets/profile/change_password_dialog.dart';
import 'package:fitness_day/core/widgets/profile/change_phone_dialog.dart';
import 'package:fitness_day/core/widgets/app_header.dart';
import 'package:fitness_day/core/widgets/app_snack_bar.dart';
import 'package:fitness_day/core/services/socket_service.dart';
import 'package:fitness_day/core/routes/user_routes/app_routes.dart';
import 'package:fitness_day/core/widgets/app_segmented_control.dart';
import 'package:fitness_day/features/user/profile/data/models/user_profile_model.dart';
import 'package:fitness_day/features/user/profile/presentation/manager/user_profile_cubit.dart';
import 'package:fitness_day/features/user/profile/presentation/manager/user_profile_state.dart';
import 'package:fitness_day/core/cache/app_cache.dart';
import 'package:fitness_day/core/cache/secure_cache.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/core/routes/shared/shared_routes.dart';
import 'package:fitness_day/core/widgets/confirm_dialog.dart';
import 'package:fitness_day/fitness_day.dart';
import '../../../user_home/presentation/widgets/user_app_drawer.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  int _selectedTab = 0; // 0 = Settings, 1 = Fitness Day

  @override
  void initState() {
    super.initState();
    context.read<UserProfileCubit>().getUserProfile();
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final cubit = context.read<UserProfileCubit>();
    final result = await cubit.deleteAccount();
    if (!context.mounted) return;

    switch (result) {
      case Success(:final data):
        getIt<SocketService>().disconnect();
        await getIt<SecureCache>().deleteToken();
        await getIt<SecureCache>().deleteRefreshToken();
        await getIt<AppCache>().clear();
        RoleNotifier.instance.setRole(AppRole.none);
        if (context.mounted) {
          context.go(SharedRoutes.roleSelection);
          showAppSnackBar(context, text: data, isSuccess: true);
        }
      case FailureResult(:final failure):
        showAppSnackBar(context, text: failure.message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        endDrawer: UserAppDrawer(isSubscribed: getIt<AppCache>().getIsSubscribed()),
      body: BlocListener<UserProfileCubit, UserProfileState>(
        listenWhen: (previous, current) => current is UserProfileUpdateFailure,
        listener: (context, state) {
          if (state is UserProfileUpdateFailure) {
            showAppSnackBar(context, text: state.message, isError: true);
          }
        },
        child: Builder(
          builder: (context) {
            return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppColors.splashBackgroundGradient,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  SizedBox(height: 20.h),

                  // Header
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: AppHeader(
                      title: 'profile.title'.tr(),
                      onMenuPressed: () {
                        Scaffold.of(context).openEndDrawer();
                      },
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // User Info Card
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: AppShadows.profileItemShadow,
                      ),
                      child: BlocBuilder<UserProfileCubit, UserProfileState>(
                        builder: (context, state) {
                          final data = state is UserProfileSuccess ? state.data : null;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Avatar + Name/Identifier (RTL Layout)
                              Row(
                                children: [
                                  Container(
                                    width: 50.r,
                                    height: 50.r,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: (data?.avatar.isNotEmpty ?? false)
                                        ? AppImage(
                                            data!.avatar,
                                            radius: 25.r,
                                            fit: BoxFit.cover,
                                          )
                                        : Center(
                                            child: AppImage(
                                              SvgIcons.person,
                                              width: 28.w,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                  ),
                                  SizedBox(width: 16.w),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        data?.fullName ?? '',
                                        style: TextStyleManager.style14Bold.copyWith(
                                          color: AppColors.black,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        data?.identifier ?? '',
                                        style: TextStyleManager.style11Medium.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  context.push(UserAppRoutes.personalProfile);
                                },
                                child: AppImage(
                                  SvgIcons.editProfile,
                                  width: 30.r,
                                  height: 30.r,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Segmented Tabs
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: AppSegmentedControl(
                      type: AppSegmentedControlType.unified,
                      items: [
                        'drawer.settings'.tr(),
                        'home.specialist_role'.tr(), // "يوم الرشاقة" / Fitness Day
                      ],
                      selectedIndex: _selectedTab,
                      onItemSelected: (index) {
                        setState(() => _selectedTab = index);
                      },
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // List of Menu Items
                  Expanded(
                    child: BlocBuilder<UserProfileCubit, UserProfileState>(
                      builder: (context, state) {
                        final data = state is UserProfileSuccess ? state.data : null;
                        return ListView(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          children: _selectedTab == 0
                              ? _buildSettingsItems(context, data)
                              : _buildFitnessDayItems(context),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
          },
        ),
      ),
    );
  }

  // ── Settings Tab ───────────────────────────────────────────────────────────
  List<Widget> _buildSettingsItems(BuildContext context, UserProfileDataModel? data) => [
        _buildMenuItem(
          title: 'profile.personal_profile'.tr(),
          iconWidget: _buildCircleIcon(iconPath: SvgIcons.profile),
          onTap: () {
            context.push(UserAppRoutes.personalProfile);
          },
        ),
        _buildMenuItem(
          title: 'profile.edit_password'.tr(),
          iconWidget: _buildCircleIcon(iconPath: SvgIcons.editPassword),
          onTap: () {
            showDialog(
              context: context,
              barrierColor: AppColors.scrimOverlay.withValues(alpha: 0.5),
              builder: (context) => const ChangePasswordDialog(),
            );
          },
        ),
        if (data?.typeOfIdentifier == 'PHONE')
          _buildMenuItem(
            title: 'profile.change_phone'.tr(),
            iconWidget: _buildCircleIcon(iconPath: SvgIcons.profile),
            onTap: () {
              showDialog(
                context: context,
                barrierColor: AppColors.scrimOverlay.withValues(alpha: 0.5),
                builder: (context) => ChangePhoneDialog(initialPhone: data?.identifier),
              );
            },
          ),
        _buildMenuItem(
          title: 'drawer.notifications_alerts'.tr(),
          iconWidget: _buildCircleIcon(iconPath: SvgIcons.notifications),
          trailing: Switch(
            value: data?.notificationsEnabled ?? true,
            activeColor: AppColors.primary,
            onChanged: (val) {
              context.read<UserProfileCubit>().toggleNotifications();
            },
          ),
          onTap: () {},
        ),
        _buildMenuItem(
          title: 'profile.language'.tr(),
          iconWidget: _buildCircleIcon(iconPath: SvgIcons.lang),
          onTap: () {
            showDialog(
              context: context,
              barrierColor: AppColors.scrimOverlay.withValues(alpha: 0.5),
              builder: (context) => const LanguageDialog(),
            );
          },
        ),
        _buildMenuItem(
          title: 'profile_page.achievements'.tr(), // "الانجازات"
          iconWidget: _buildCircleIcon(iconPath: SvgIcons.achievements),
          onTap: () {
            context.push(UserAppRoutes.achievements);
          },
        ),
        _buildMenuItem(
          title: 'home.category_progress'.tr(), // "التقدم"
          iconWidget: _buildCircleIcon(iconPath: SvgIcons.progress),
          onTap: () {
            context.push(UserAppRoutes.progress);
          },
        ),
        _buildMenuItem(
          title: 'profile_page.awards'.tr(), // "الجوائز"
          iconWidget: _buildCircleIcon(iconPath: SvgIcons.rewards),
          onTap: () {
            context.push(UserAppRoutes.awards);
          },
        ),
        _buildMenuItem(
          title: 'profile_page.delete_account'.tr(), // "حذف الحساب"
          iconWidget: _buildCircleIcon(
            iconPath: SvgIcons.deleteAccount,
            backgroundColor: AppColors.red.withValues(alpha: 0.1),
            iconColor: AppColors.red,
          ),
          onTap: () {
            showDialog(
              context: context,
              builder: (dialogContext) => ConfirmDialog(
                svgIcon: SvgIcons.deleteAccount,
                title: 'profile_page.delete_account'.tr(),
                subtitle: 'profile_page.delete_account_confirm'.tr(),
                confirmText: 'profile_page.delete_account_button'.tr(),
                cancelText: 'profile.cancel'.tr(),
                accentColor: AppColors.error,
                onConfirm: () => _deleteAccount(context),
              ),
            );
          },
        ),
        SizedBox(height: 24.h),
      ];

  // ── Fitness Day Tab ────────────────────────────────────────────────────────
  List<Widget> _buildFitnessDayItems(BuildContext context) => [
        _buildMenuItem(
          title: 'profile.about_us'.tr(),
          iconWidget: _buildCircleIcon(iconPath: SvgIcons.aboutUs),
          onTap: () {},
        ),
        _buildMenuItem(
          title: 'profile.privacy_policy'.tr(),
          iconWidget: _buildCircleIcon(iconPath: SvgIcons.privacy),
          onTap: () {},
        ),
        _buildMenuItem(
          title: 'profile.terms_conditions'.tr(),
          iconWidget: _buildCircleIcon(iconPath: SvgIcons.conditions),
          onTap: () {},
        ),
        _buildMenuItem(
          title: 'profile_page.rate_app'.tr(), // "قيم التطبيق"
          iconWidget: _buildCircleIcon(iconPath: SvgIcons.rate),
          onTap: () {},
        ),
        SizedBox(height: 24.h),
      ];

  // Helper to build circular icon wrapper
  Widget _buildCircleIcon({
    String? iconPath,
    IconData? iconData,
    Color backgroundColor = const Color(0xFFFAFDFA),
    Color iconColor = AppColors.primary,
  }) {
    return Center(
      child: iconPath != null
          ? AppImage(
              iconPath,
              width: 40.r,
              height: 40.r,
            )
          : Icon(
              iconData,
              size: 22.sp,
              color: iconColor,
            ),
    );
  }

  // Helper to build menu item row
  Widget _buildMenuItem({
    required String title,
    required Widget iconWidget,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.white, AppColors.dialogBackground],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: AppColors.dividerLight,
            width: 0.2.w,
          ),
          boxShadow: AppShadows.profileItemShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            // Right visual side (Icon + Text)
            Row(
              children: [
                iconWidget,
                SizedBox(width: 16.w),
                Text(title, style: TextStyleManager.style11Medium),
              ],
            ),

            // Left visual side (trailing or arrow)
            trailing ??
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.primary,
                  size: 16.sp,
                ),
          ],
        ),
      ),
    );
  }
}
