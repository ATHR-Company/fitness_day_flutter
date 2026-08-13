import 'dart:async';
import 'dart:collection';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/services/app_event_bus.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/core/widgets/app_image.dart';
import 'package:fitness_day/features/user/challenges/data/models/achievement_model.dart';
import 'package:fitness_day/features/user/challenges/presentation/manager/challenges_events.dart';
import 'package:fitness_day/features/user/profile/presentation/pages/achievements_page.dart';

/// Surfaces a badge the moment the server says it was unlocked.
///
/// Wrapped around the whole app rather than owned by a screen: badges unlock on
/// an `/activity-sync` response, and that sync runs while the user could be
/// anywhere — mid-walk on the steps screen, or logging water. Without a global
/// listener the badge would only ever be discovered later, by opening
/// الانجازات, which is not a celebration.
///
/// Rendered as an in-tree overlay, not a route. It sits above `MaterialApp`'s
/// navigator (the same slot as the offline banner), where there is no
/// `Navigator` to push a dialog onto — and staying out of the navigator also
/// means it cannot be popped by a back gesture aimed at the screen underneath,
/// or dismissed by a route transition happening at the same moment.
class AchievementUnlockedOverlay extends StatefulWidget {
  final Widget child;

  const AchievementUnlockedOverlay({super.key, required this.child});

  @override
  State<AchievementUnlockedOverlay> createState() =>
      _AchievementUnlockedOverlayState();
}

class _AchievementUnlockedOverlayState
    extends State<AchievementUnlockedOverlay> {
  StreamSubscription<AppEvent>? _sub;
  Timer? _dismissTimer;

  /// One sync can unlock several badges at once, complete a challenge in the
  /// same breath, and be followed immediately by another sync. They are shown
  /// one at a time rather than stacked on top of each other.
  final Queue<_Celebration> _queue = Queue<_Celebration>();
  _Celebration? _current;

  /// How long each one stays up before the next takes its turn.
  static const Duration _kVisible = Duration(seconds: 4);

  @override
  void initState() {
    super.initState();
    _sub = getIt<AppEventBus>().stream.listen(_onEvent);
  }

  void _onEvent(AppEvent event) {
    if (!mounted) return;

    switch (event) {
      // The backend has already diffed these — they were unlocked by that one
      // sync and by nothing before it, so there is nothing to compare against
      // and no risk of celebrating the same badge twice.
      case AchievementsUnlocked(:final achievements):
        if (achievements.isEmpty) return;
        _queue.addAll(achievements.map(_Celebration.forAchievement));

      // Challenges that crossed their goal on that same sync. Always zero on a
      // replay, so a retried request cannot re-congratulate the user.
      case ActivityLedgerChanged(:final completedChallenges):
        if (completedChallenges <= 0) return;
        // The response says how many finished, not which — every entry in
        // `challenges` carries `isCompleted`, but that is also true of ones
        // completed days ago. So this is deliberately worded without naming a
        // challenge rather than guessing at the wrong one.
        _queue.add(_Celebration.forCompletedChallenges());

      default:
        return;
    }

    if (_current == null) _showNext();
  }

  void _showNext() {
    _dismissTimer?.cancel();
    if (_queue.isEmpty) {
      setState(() => _current = null);
      return;
    }
    setState(() => _current = _queue.removeFirst());
    _dismissTimer = Timer(_kVisible, () {
      if (mounted) _showNext();
    });
  }

  void _dismiss() {
    if (_current != null) _showNext();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _dismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _Celebration? current = _current;

    return Stack(
      children: [
        widget.child,
        // Below the offline banner's slot by construction (this wraps inside
        // it), so a lost connection still takes visual priority.
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SafeArea(
            top: false,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              offset: current == null ? const Offset(0, 1.4) : Offset.zero,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: current == null ? 0 : 1,
                child: current == null
                    ? const SizedBox.shrink()
                    : _CelebrationCard(
                        celebration: current,
                        onDismiss: _dismiss,
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// One thing worth congratulating the user for, already resolved down to what
/// the card renders. Keeping the widget free of the event types means a new
/// kind of celebration is a new factory here rather than another branch in the
/// layout.
class _Celebration {
  /// Small line above the name — "New achievement!", "Challenge completed".
  final String Function() label;

  /// The server's own wording where there is any. Never built from `code`.
  final String title;
  final String body;

  /// Asset path or remote URL; [AppImage] handles either.
  final String image;

  const _Celebration({
    required this.label,
    required this.title,
    required this.body,
    required this.image,
  });

  factory _Celebration.forAchievement(AchievementModel a) {
    final String? image = a.image;
    return _Celebration(
      label: () => 'achievements.unlocked_title'.tr(),
      // Dashboard-editable and already translated to the `lang` header.
      title: a.name,
      body: a.description,
      image: image == null || image.isEmpty
          ? AchievementRow.iconFor(a.code)
          : image,
    );
  }

  /// Worded without a count or a name on purpose — see the note at the call
  /// site: the sync reports how many finished, not which. Several finishing at
  /// once is rare enough not to justify plural forms in two languages.
  factory _Celebration.forCompletedChallenges() {
    return _Celebration(
      label: () => 'challenges.screen_title'.tr(),
      title: 'challenges.completed'.tr(),
      body: '',
      image: SvgIcons.achievement,
    );
  }
}

class _CelebrationCard extends StatelessWidget {
  final _Celebration celebration;
  final VoidCallback onDismiss;

  const _CelebrationCard({required this.celebration, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: onDismiss,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.primary, width: 1.5.w),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 48.r,
                  height: 48.r,
                  child: AppImage(
                    celebration.image,
                    width: 48.r,
                    height: 48.r,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Resolved at build time, not when the event arrived, so
                      // a language change mid-celebration reads correctly.
                      Text(
                        celebration.label(),
                        style: TextStyleManager.style11Medium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        celebration.title,
                        style: TextStyleManager.style14Bold.copyWith(
                          color: AppColors.black,
                        ),
                      ),
                      if (celebration.body.isNotEmpty) ...[
                        SizedBox(height: 2.h),
                        Text(
                          celebration.body,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyleManager.style11Medium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
