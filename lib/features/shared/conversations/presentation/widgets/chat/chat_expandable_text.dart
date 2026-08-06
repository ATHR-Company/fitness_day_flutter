import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:fitness_day/core/theme/app_colors.dart';

/// Message body that clamps to [maxLines] and reveals the rest on demand.
///
/// A long message would otherwise take over the whole viewport and push every
/// other bubble off screen, so anything past the clamp is collapsed behind a
/// "show more" toggle. The toggle only appears when the text really overflows —
/// measured, not guessed from its length — so short messages look untouched.
class ChatExpandableText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final TextAlign textAlign;

  /// Lines shown while collapsed.
  final int maxLines;

  const ChatExpandableText({
    super.key,
    required this.text,
    required this.style,
    this.textAlign = TextAlign.start,
    this.maxLines = 8,
  });

  @override
  State<ChatExpandableText> createState() => _ChatExpandableTextState();
}

class _ChatExpandableTextState extends State<ChatExpandableText> {
  bool _expanded = false;

  /// A message can be edited in place (the optimistic bubble is swapped for the
  /// server one), and the list recycles this State between messages — either
  /// way the new text has its own length, so start it collapsed.
  @override
  void didUpdateWidget(covariant ChatExpandableText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text && _expanded) {
      setState(() => _expanded = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: widget.text, style: widget.style),
          maxLines: widget.maxLines,
          textAlign: widget.textAlign,
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout(maxWidth: constraints.maxWidth);

        final bool overflows = painter.didExceedMaxLines;
        painter.dispose();

        final Widget body = Text(
          widget.text,
          textAlign: widget.textAlign,
          style: widget.style,
          maxLines: _expanded ? null : widget.maxLines,
          overflow: _expanded ? TextOverflow.clip : TextOverflow.ellipsis,
        );

        if (!overflows) return body;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            body,
            SizedBox(height: 2.h),
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              // The label is small; padding gives it a finger-sized target
              // without moving it away from the text.
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 3.h),
                child: Text(
                  _expanded
                      ? 'conversations.show_less'.tr()
                      : 'conversations.show_more'.tr(),
                  style: widget.style.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
