import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:fitness_day/core/routes/shared/shared_routes.dart';
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
    if (mounted) {
      context.go(SharedRoutes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  child: SvgPicture.asset(SvgIcons.apple),
                ),
                
                // Person inside the apple
                Transform.translate(
                  offset: const Offset(0, 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Head
                      Transform.translate(
                        offset: const Offset(0, 10), // Move head slightly down
                        child: AnimatedSlide(
                          offset: _showHead ? Offset.zero : const Offset(0, -1),
                          duration: const Duration(seconds: 2),
                          curve: Curves.elasticOut,
                          child: AnimatedOpacity(
                            opacity: _showHead ? 1.0 : 0.0,
                            duration: const Duration(seconds: 2),
                            child: SvgPicture.asset(SvgIcons.head),
                          ),
                        ),
                      ),
                      
                      // Body (Swapped left and right so they form the correct shape)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Transform.translate(
                            offset: const Offset(0, 2), // Lower the visually right element
                            child: AnimatedSlide(
                              offset: _showLeftRight ? Offset.zero : const Offset(-1, 0),
                              duration: const Duration(seconds: 2),
                              curve: Curves.elasticOut,
                              child: AnimatedOpacity(
                                opacity: _showLeftRight ? 1.0 : 0.0,
                                duration: const Duration(seconds: 2),
                                child: SvgPicture.asset(SvgIcons.right),
                              ),
                            ),
                          ),
                          
                          Transform.translate(
                            offset: const Offset(0, -10), // Raise the visually left element
                            child: AnimatedSlide(
                              offset: _showLeftRight ? Offset.zero : const Offset(1, 0),
                              duration: const Duration(seconds: 2),
                              curve: Curves.elasticOut,
                              child: AnimatedOpacity(
                                opacity: _showLeftRight ? 1.0 : 0.0,
                                duration: const Duration(seconds: 1),
                                child: SvgPicture.asset(SvgIcons.left),
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
            
            const SizedBox(height: 16),
            
            // App Name
            AnimatedSlide(
              offset: _showAppName ? Offset.zero : const Offset(0, 1),
              duration: const Duration(seconds: 2),
              curve: Curves.elasticOut,
              child: AnimatedOpacity(
                opacity: _showAppName ? 1.0 : 0.0,
                duration: const Duration(seconds: 1),
                child: SvgPicture.asset(SvgIcons.appName),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
