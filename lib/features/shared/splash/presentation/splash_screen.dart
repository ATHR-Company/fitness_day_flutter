import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:fitness_day/core/routes/shared/shared_routes.dart';
import 'package:fitness_day/core/cache/app_cache.dart';
import 'package:fitness_day/core/cache/secure_cache.dart';
import 'package:fitness_day/core/injection/injection_container.dart' as di;

import '../../../../core/routes/user_routes/app_routes.dart';
import '../../../../core/routes/specialist_routes/app_routes.dart';
import 'package:fitness_day/fitness_day.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _showApple = false;
  bool _showLeftRight = false;
  bool _showHead = false;
  bool _showAppName = false;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() async {
    // 1. Apple appear in the middle
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _showApple = true;
    });

    // 2. Left and Right come in the same time
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _showLeftRight = true;
    });

    // 3. Head come from top
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _showHead = true;
    });

    // 4. App Name come from bottom
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _showAppName = true;
    });

    // Navigate to next screen after animation completes
    await Future.delayed(const Duration(seconds: 2));
    final appCache = di.getIt<AppCache>();
    await _repairOrphanedSession(appCache);
    if (mounted) {
      if (appCache.isLoggedIn()) {
        final userType = appCache.getUserType();
        if (userType == 'specialist') {
          RoleNotifier.instance.setRole(AppRole.specialist);
          context.go(SpecialistAppRoutes.home);
        } else {
          RoleNotifier.instance.setRole(AppRole.user);
          // `isLoggedIn` is only ever persisted once onboarding (personal
          // data + health survey) is fully complete, so reaching here always
          // means it's safe to go straight to home.
          context.go(UserAppRoutes.home);
        }
      } else if (appCache.hasSeenOnboarding()) {
        context.go(SharedRoutes.roleSelection);
      } else {
        context.go(SharedRoutes.onboarding);
      }
    }
  }

  /// Clears `is_logged_in` when the tokens behind it are gone.
  ///
  /// The flag lives in GetStorage (a plain file) and the tokens in
  /// FlutterSecureStorage (encrypted with a key held in the Android Keystore).
  /// A restored backup brings the encrypted blob without the Keystore key, and
  /// some OEMs drop the key on reinstall; either way the plugin wipes the
  /// unreadable blob and returns null while the flag survives.
  ///
  /// Trusting the flag alone sent the app straight to Home, where every request
  /// went out with no Authorization header and came back 401 — the app looked
  /// broken until the user cleared its data. Checking here means that install
  /// simply starts at role selection, which is what a logged-out app should do.
  Future<void> _repairOrphanedSession(AppCache appCache) async {
    if (!appCache.isLoggedIn()) return;

    String? token;
    String? refreshToken;
    try {
      final secureCache = di.getIt<SecureCache>();
      token = await secureCache.getToken();
      refreshToken = await secureCache.getRefreshToken();
    } catch (_) {
      // An unreadable keystore is itself a missing credential — fall through
      // and treat this install as logged out.
    }

    final bool hasCredentials = (token != null && token.isNotEmpty) ||
        (refreshToken != null && refreshToken.isNotEmpty);
    if (hasCredentials) return;

    debugPrint('[Splash] session flag with no token — clearing local session');
    await appCache.clearSession();
  }

  @override
  Widget build(BuildContext context) {
    // Force RTL so the splash logo animates identically in both languages.
    // The splash has no localised text, so this has no visible side-effect.
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Middle section (Apple with Head, Left and Right inside)
              Stack(
                alignment: Alignment.center,
                children: [
                  // Apple
                  AnimatedScale(
                    scale: _showApple ? 1.0 : 0.0,
                    duration: const Duration(seconds: 2),
                    curve: Curves.elasticOut,
                    child: AppImage(SvgIcons.apple),
                  ),

                  // Person inside the apple
                  Transform.translate(

                    offset: Offset(0, 8.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Head
                        Transform.translate(
                          offset: Offset(0, 10.h), // Move head slightly down
                          child: AnimatedSlide(
                            offset: _showHead ? Offset.zero : const Offset(0, -1),
                            duration: const Duration(seconds: 2),
                            curve: Curves.elasticOut,
                            child: AnimatedOpacity(
                              opacity: _showHead ? 1.0 : 0.0,
                              duration: const Duration(seconds: 2),
                              child: AppImage(SvgIcons.head),
                            ),
                          ),
                        ),

                        // Body (Swapped left and right so they form the correct shape)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Transform.translate(
                              offset: Offset(0, 2.h), // Lower the visually right element
                              child: AnimatedSlide(
                                offset: _showLeftRight ? Offset.zero : const Offset(-1, 0),
                                duration: const Duration(seconds: 2),
                                curve: Curves.elasticOut,
                                child: AnimatedOpacity(
                                  opacity: _showLeftRight ? 1.0 : 0.0,
                                  duration: const Duration(seconds: 2),
                                  child: AppImage(SvgIcons.right),
                                ),
                              ),
                            ),

                            Transform.translate(
                              offset: Offset(0, -10.h), // Raise the visually left element
                              child: AnimatedSlide(
                                offset: _showLeftRight ? Offset.zero : const Offset(1, 0),
                                duration: const Duration(seconds: 2),
                                curve: Curves.elasticOut,
                                child: AnimatedOpacity(
                                  opacity: _showLeftRight ? 1.0 : 0.0,
                                  duration: const Duration(seconds: 1),
                                  child: AppImage(SvgIcons.left),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // App Name
              AnimatedSlide(
                offset: _showAppName ? Offset.zero : const Offset(0, 1),
                duration: const Duration(seconds: 2),
                curve: Curves.elasticOut,
                child: AnimatedOpacity(
                  opacity: _showAppName ? 1.0 : 0.0,
                  duration: const Duration(seconds: 1),
                  child: AppImage(SvgIcons.appName),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
