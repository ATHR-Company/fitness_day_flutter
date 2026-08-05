import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

SnackBar appSnackBar(
  BuildContext context, {
  required String text,
  bool isError = false,
  bool isSuccess = false,
}) {
  return SnackBar(
    behavior: SnackBarBehavior.floating,
    elevation: 8,
    margin: EdgeInsets.only(
      bottom: 30.h,
      right: 20.w,
      left: 20.w,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18.r),
    ),
    duration: const Duration(milliseconds: 2500),
    backgroundColor: isError
        ? AppColors.error
        : isSuccess
            ? AppColors.success
            : AppColors.primary,
    padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
    content: Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyleManager.heading3.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

void showAppSnackBar(
  BuildContext context, {
  required String text,
  bool isError = false,
  bool isSuccess = false,
}) {
  final overlay = Overlay.of(context, rootOverlay: true);

  final color = isError
      ? AppColors.error
      : isSuccess
          ? AppColors.success
          : AppColors.primary;

  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _OverlaySnackBar(
      text: text,
      color: color,
      onDone: () => entry.remove(),
    ),
  );

  overlay.insert(entry);
}

class _OverlaySnackBar extends StatefulWidget {
  final String text;
  final Color color;
  final VoidCallback onDone;

  const _OverlaySnackBar({
    required this.text,
    required this.color,
    required this.onDone,
  });

  @override
  State<_OverlaySnackBar> createState() => _OverlaySnackBarState();
}

class _OverlaySnackBarState extends State<_OverlaySnackBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    _ctrl.forward();

    Future.delayed(const Duration(milliseconds: 2500), () async {
      if (mounted) {
        await _ctrl.reverse();
        widget.onDone();
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 40,
      left: 20,
      right: 20,
      child: FadeTransition(
        opacity: _opacity,
        child: SlideTransition(
          position: _slide,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(18.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                widget.text,
                textAlign: TextAlign.center,
                style: TextStyleManager.heading3.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
