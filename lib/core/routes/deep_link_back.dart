import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:fitness_day/core/cache/app_cache.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/routes/specialist_routes/app_routes.dart';
import 'package:fitness_day/core/routes/user_routes/app_routes.dart';

/// Back behaviour for the screens an App Link can open cold.
///
/// A link hands GoRouter the destination directly — the splash never runs and
/// nothing is pushed underneath — so the screen *is* the whole navigator. An
/// unguarded `Navigator.pop` there pops the only page and leaves an empty
/// navigator, which renders as a black screen.
///
/// Home is the right landing spot rather than closing the app: the user came in
/// from outside, so "back" means further into the app, not out of it.
class DeepLinkBack {
  const DeepLinkBack._();

  /// Pops normally when there is history, otherwise lands on the role's home.
  static void pop(BuildContext context) {
    final NavigatorState navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }
    context.go(home);
  }

  /// Whichever home the current session belongs to — a specialist following a
  /// user-side link must not be dropped on the user home.
  static String get home {
    try {
      return getIt<AppCache>().getUserType() == 'specialist'
          ? SpecialistAppRoutes.home
          : UserAppRoutes.home;
    } catch (_) {
      return UserAppRoutes.home;
    }
  }
}

/// Makes the system back gesture behave like [DeepLinkBack.pop].
///
/// Covers the half an in-app back button cannot: the hardware button and the
/// edge-swipe both go through `PopScope`, and on a link-opened screen those
/// would otherwise close the app outright.
class DeepLinkPopScope extends StatelessWidget {
  final Widget child;

  const DeepLinkPopScope({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // When there IS history, let the framework pop as usual — intercepting it
    // would break every normal in-app path onto this screen.
    final bool hasHistory = Navigator.of(context).canPop();

    return PopScope(
      canPop: hasHistory,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        context.go(DeepLinkBack.home);
      },
      child: child,
    );
  }
}
