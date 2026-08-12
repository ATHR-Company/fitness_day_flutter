import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'package:fitness_day/core/cache/app_cache.dart';
import 'package:fitness_day/core/cache/secure_cache.dart';
import 'package:fitness_day/core/routes/app_router.dart';
import 'package:fitness_day/core/routes/shared/shared_routes.dart';
import 'package:fitness_day/core/services/socket_service.dart';
import 'package:fitness_day/core/widgets/app_snack_bar.dart';
import 'package:fitness_day/fitness_day.dart';

/// Why the session ended, which is the only thing the user needs told apart.
enum SessionEndReason {
  /// The token ran out and could not be renewed — ordinary, nobody's fault.
  expired,

  /// The account signed in somewhere else. The backend allows one live session
  /// per account, so this device's was revoked the moment the other one
  /// started.
  loggedInElsewhere,
}

/// Ends the local session and returns the app to role selection.
///
/// One place, because the end of a session arrives through two channels and
/// both must leave the app in exactly the same state:
///
///   * `forceLogout` over the socket — instant, but only reaches a device that
///     is online at that moment;
///   * a `401` carrying `key: "session_revoked"` — slower, but it cannot be
///     missed: a device that was offline discovers it on its next request.
///
/// The socket event is the courtesy; the 401 is the guarantee.
class SessionManager {
  final SecureCache _secureCache;

  SessionManager({required SecureCache secureCache})
      : _secureCache = secureCache;

  /// Guards the window between "we decided to end the session" and "the token
  /// is actually gone". A burst of parallel requests all failing with 401 would
  /// otherwise each run the teardown and stack a navigation per response.
  bool _ending = false;

  /// Tears everything down: socket, tokens, cached session, role, route.
  ///
  /// Safe to call repeatedly — once the token is gone there is no session left
  /// to end, so later calls return without touching the screen the user has
  /// already been sent to.
  Future<void> endSession({
    required SessionEndReason reason,
    String? serverMessage,
  }) async {
    if (_ending) return;
    _ending = true;
    try {
      final String? token = await _secureCache.getToken();
      final String? refreshToken = await _secureCache.getRefreshToken();
      final bool hadSession = (token != null && token.isNotEmpty) ||
          (refreshToken != null && refreshToken.isNotEmpty);
      if (!hadSession) return;

      debugPrint('[Session] 🔚 Ending session — reason=${reason.name}');

      // Socket first. It authenticates with the same token and reconnects on
      // its own, so leaving it up means a dead session that keeps knocking.
      try {
        GetIt.instance<SocketService>().disconnect();
      } catch (_) {}

      await _secureCache.deleteToken();
      await _secureCache.deleteRefreshToken();

      try {
        // clearSession(), not clear(): the onboarding flag describes the
        // install, not the session, and re-showing onboarding on a forced
        // logout would be wrong.
        await GetIt.instance<AppCache>().clearSession();
      } catch (_) {}

      RoleNotifier.instance.setRole(AppRole.none);

      // Read fresh from the navigator key rather than captured before the
      // awaits — there is no stale context to carry across the gap, which is
      // what the lint is there to catch.
      final BuildContext? context = AppRouter.navigatorKey.currentContext;
      // ignore: use_build_context_synchronously
      if (context != null) context.go(SharedRoutes.roleSelection);

      _announce(reason, serverMessage);
    } finally {
      _ending = false;
    }
  }

  /// Tells the user why they are suddenly looking at the login screen.
  ///
  /// Deferred by a frame so the message lands on the route being navigated to
  /// rather than the one being torn down.
  void _announce(SessionEndReason reason, String? serverMessage) {
    if (reason != SessionEndReason.loggedInElsewhere) return;

    // The backend's own wording wins when it sent one — it is already in the
    // right language and may be more specific than the local copy.
    final String text = (serverMessage != null && serverMessage.trim().isNotEmpty)
        ? serverMessage
        : 'errors.session_revoked'.tr();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final BuildContext? context = AppRouter.navigatorKey.currentContext;
      if (context == null) return;
      showAppSnackBar(context, text: text, isError: true);
    });
  }
}
