import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

/// How long the backend makes a caller wait between verification codes.
///
/// Only ever used to open the countdown after a code goes out, where the reply
/// says nothing about timing. A refusal always carries the real number of
/// seconds left and overrides this, so a change on the server corrects itself
/// within one tap instead of needing a release.
const int kResendCooldownSeconds = 60;

/// Counts down the wait between verification codes.
///
/// Split from the button so the screen can drive it from wherever its result
/// arrives — a Bloc listener, an awaited call — while the button stays a plain
/// piece of presentation. Every OTP screen shares one behaviour this way rather
/// than each growing its own timer.
class ResendCountdown extends ChangeNotifier {
  Timer? _timer;
  int _seconds = 0;

  int get seconds => _seconds;
  bool get canResend => _seconds == 0;

  /// Restarts the wait. A value of zero or less unlocks the button immediately.
  void start(int seconds) {
    _timer?.cancel();
    _seconds = seconds > 0 ? seconds : 0;
    notifyListeners();
    if (_seconds == 0) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _seconds--;
      if (_seconds <= 0) {
        _seconds = 0;
        timer.cancel();
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// "Resend code", or the wait remaining before it means anything.
class ResendCodeButton extends StatelessWidget {
  final ResendCountdown countdown;
  final VoidCallback onResend;

  const ResendCodeButton({
    super.key,
    required this.countdown,
    required this.onResend,
  });

  /// `m:ss` past a minute, plain seconds below it — Latin digits either way, so
  /// a ticking number never changes shape as it counts down.
  static String _format(int seconds) {
    if (seconds < 60) return '$seconds';
    final int minutes = seconds ~/ 60;
    final String rest = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$rest';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: countdown,
      builder: (context, _) {
        final bool canResend = countdown.canResend;
        return TextButton(
          onPressed: canResend ? onResend : null,
          child: Text(
            canResend
                ? 'login.resend_code'.tr()
                : 'login.resend_code_in'.tr(args: [_format(countdown.seconds)]),
            style: TextStyleManager.style14Bold.copyWith(
              color: canResend ? AppColors.primary : AppColors.textSecondary,
              // Only the live link is underlined — underlining the countdown
              // would keep offering something that isn't there yet.
              decoration:
                  canResend ? TextDecoration.underline : TextDecoration.none,
            ),
          ),
        );
      },
    );
  }
}
