import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Three dots that bounce in sequence, used inside "… is typing" bubbles.
class TypingDotsIndicator extends StatefulWidget {
  final Color color;
  final double dotSize;

  const TypingDotsIndicator({
    super.key,
    required this.color,
    this.dotSize = 6,
  });

  @override
  State<TypingDotsIndicator> createState() => _TypingDotsIndicatorState();
}

class _TypingDotsIndicatorState extends State<TypingDotsIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const List<double> _startFractions = [0.0, 0.2, 0.4];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final animation = CurvedAnimation(
          parent: _controller,
          curve: Interval(
            _startFractions[index],
            _startFractions[index] + 0.6,
            curve: Curves.easeInOut,
          ),
        );
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              final double bounce = Curves.easeInOut.transform(
                (1 - (animation.value - 0.5).abs() * 2).clamp(0.0, 1.0),
              );
              return Transform.translate(
                offset: Offset(0, -bounce * 4.h),
                child: Opacity(
                  opacity: 0.4 + bounce * 0.6,
                  child: child,
                ),
              );
            },
            child: Container(
              width: widget.dotSize.w,
              height: widget.dotSize.w,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      }),
    );
  }
}
