import 'package:flutter/material.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/theme/app_colors.dart';

/// Widget خلفية مشتركة — gradient + decor SVG في الأسفل
/// استخدامه:
/// ```dart
/// ScreenBackground(
///   child: SafeArea(child: ...),
/// )
/// ```
class ScreenBackground extends StatelessWidget {
  final Widget child;

  /// لون الـ decor SVG — افتراضي شبه شفاف
  final Color? decorColor;

  /// Gradient الخلفية — افتراضي `AppColors.profileGradient`
  final Gradient? gradient;

  const ScreenBackground({
    super.key,
    required this.child,
    this.decorColor,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ── gradient background ───────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            gradient: gradient ?? AppColors.profileGradient,
          ),
        ),

        // ── decor SVG (top-left, non-interactive) ───────────────────────
        Positioned(
          top: 0,
          left: 0,
          child: IgnorePointer(
            child: AppImage(
              SvgIcons.stepsDecor,
              color: decorColor ?? const Color.fromARGB(15, 0, 100, 20),
              fit: BoxFit.cover,
            ),
          ),
        ),

        // ── page content ──────────────────────────────────────────────────
        child,
      ],
    );
  }
}
