import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';
import 'package:fitness_day/core/routes/shared/shared_routes.dart';
import 'package:fitness_day/features/specialist/auth/presentation/manager/auth_cubit.dart';
import 'package:fitness_day/features/specialist/auth/presentation/manager/auth_state.dart';
import 'package:fitness_day/fitness_day.dart';
import 'package:fitness_day/core/cache/secure_cache.dart';
import 'package:fitness_day/core/cache/app_cache.dart';
import 'package:fitness_day/core/services/socket_service.dart';
import 'package:fitness_day/core/injection/injection_container.dart' as di;
import 'package:fitness_day/features/user/profile/presentation/manager/user_profile_cubit.dart';
import 'package:fitness_day/core/widgets/app_snack_bar.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/core/network/apple_sign_in_helper.dart';


class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.r),
      ),
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top light green header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: AppColors.lightGreenBackground2, // Light green
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.r),
                topRight: Radius.circular(24.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end, // Left side in RTL
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close, color: AppColors.primary, size: 24.sp),
                ),
              ],
            ),
          ),
          
          // Icon in the middle
          SizedBox(height: 32.h),
          Container(
            width: 100.r,
            height: 100.r,
            decoration: BoxDecoration(
              color: AppColors.lightGreenBackground2, // Light green background
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(0),
              child: Icon(
                Icons.logout,
                size: 40.sp,
                color: AppColors.primary,
              ),
            ),
          ),
          SizedBox(height: 24.h),
          
          // Title
          Text(
            'drawer.logout_title'.tr(),
            style: TextStyleManager.heading2.copyWith(color: AppColors.black),
          ),
          SizedBox(height: 16.h),
          
          // Subtitle
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Text(
              'drawer.logout_message'.tr(),
              textAlign: TextAlign.center,
              style: TextStyleManager.style11Medium.copyWith(color: AppColors.textSecondary),
            ),
          ),
          SizedBox(height: 32.h),
          
          // Buttons
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text(
                      'drawer.logout_cancel'.tr(),
                      style: TextStyleManager.style14Bold.copyWith(color: AppColors.primary),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: BlocConsumer<AuthCubit, AuthState>(
                    listener: (context, state) {
                      if (state is AuthLoggedOut) {
                        Navigator.pop(context);
                        context.go(SharedRoutes.roleSelection);
                      }
                    },
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      return ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                final role = RoleNotifier.instance.value;
                                if (role == AppRole.specialist) {
                                  final error = await context.read<AuthCubit>().logout();
                                  if (error != null && context.mounted) {
                                    showAppSnackBar(context, text: error, isError: true);
                                  }
                                } else {
                                  // User logout — requires network; block if offline.
                                  final signoutResult = await di.getIt<UserProfileCubit>().signout();
                                  if (signoutResult is FailureResult) {
                                    if (context.mounted) {
                                      showAppSnackBar(context, text: signoutResult.failure.message, isError: true);
                                    }
                                    return;
                                  }
                                  di.getIt<SocketService>().disconnect();
                                  // Both Apple and Google go through Firebase
                                  // Auth — leaving that session alive keeps a
                                  // signed-in Firebase user after logout.
                                  await AppleSignInHelper.signOut();
                                  await di.getIt<SecureCache>().deleteToken();
                                  await di.getIt<SecureCache>().deleteRefreshToken();
                                  await di.getIt<AppCache>().clearSession();
                                  RoleNotifier.instance.setRole(AppRole.none);
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    context.go(SharedRoutes.roleSelection);
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.r),
                          ),
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                        child: isLoading
                            ? SizedBox(
                                width: 20.r,
                                height: 20.r,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                'drawer.logout_confirm'.tr(),
                                style: TextStyleManager.style14Bold.copyWith(color: AppColors.white),
                              ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }
}
