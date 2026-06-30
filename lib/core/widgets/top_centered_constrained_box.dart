import 'package:flutter/material.dart';

class TopCenteredConstrainedBox extends StatelessWidget {
  const TopCenteredConstrainedBox({
    super.key,
    required this.child,
    this.maxWidth = 480,
    this.horizontalPadding = 24,
  });

  final Widget child;
  final double maxWidth;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: child,
        ),
      ),
    );
  }
}
