import 'package:fitness_day/core/cache/app_cache.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/routes/shared/shared_routes.dart';
import 'package:fitness_day/core/routes/specialist_routes/app_routes.dart';
import 'package:fitness_day/core/routes/user_routes/app_routes.dart';
import 'package:fitness_day/fitness_day.dart';
import 'package:go_router/go_router.dart';

/// Auth gate for links that enter the app from outside it.
///
/// An App Link bypasses the splash screen entirely — the OS hands the target
/// location straight to GoRouter, so none of the checks the splash normally
/// performs (is there a session? which role?) have run by the time the
/// destination is built. This guard puts them back, as a router-level
/// `redirect`.
///
/// Three cases it handles:
///
/// 1. **Signed out** — the link is parked and the app falls back to its normal
///    cold-start flow (splash → onboarding / role selection). Nothing is lost:
///    the parked link is replayed the moment the auth flow lands on home.
/// 2. **Signed in as a specialist** — user-side links have no specialist
///    equivalent, so they are dropped and the specialist keeps their own home.
/// 3. **Signed in as a user** — the session role is set (the splash would
///    normally have done it) and the link opens as-is.
class DeepLinkGuard {
  const DeepLinkGuard._();

  /// A link that arrived while signed out, held until authentication finishes.
  ///
  /// Static rather than injected because it has to survive from before the
  /// widget tree exists (cold start via a link) until well after the auth flow
  /// completes, and it is read from inside GoRouter's redirect where there is
  /// no reliable BuildContext.
  static String? _pending;

  /// Routes that a public web link is allowed to open directly.
  ///
  /// Deliberately a small allow-list rather than "every route": these are the
  /// only ones that make sense as an entry point with no in-app history behind
  /// them. Screens like `/meal-details` are excluded because they need an
  /// `extra` map the link cannot carry.
  static const Set<String> _entryPoints = {
    UserAppRoutes.home,
    UserAppRoutes.profile,
    UserAppRoutes.challenges,
    UserAppRoutes.store,
    UserAppRoutes.openApp,
  };

  /// GoRouter `redirect` callback. Returns null to let navigation proceed.
  static String? resolve(GoRouterState state) {
    final location = state.matchedLocation;
    final cache = getIt<AppCache>();
    final isLoggedIn = cache.isLoggedIn();
    final isSpecialist = cache.getUserType() == 'specialist';

    // ── Replay a parked link once the session exists ──────────────────────
    if (isLoggedIn && _pending != null) {
      if (isSpecialist) {
        // Signed in on the wrong side of the app — drop it rather than
        // leaving it to fire on some later navigation to the user home.
        _pending = null;
      } else if (location == UserAppRoutes.home) {
        // Every user-side auth exit (login, signup, OTP, BMI report) lands
        // here, which is why the replay hangs off home instead of being wired
        // into each of those screens individually.
        final target = _pending;
        _pending = null;
        return target;
      }
    }

    if (!_isEntryPoint(location)) return null;

    // ── Signed out: park and fall back to the normal cold-start flow ──────
    if (!isLoggedIn) {
      _pending = state.uri.toString();
      return SharedRoutes.splash;
    }

    if (isSpecialist) return SpecialistAppRoutes.home;

    // The splash sets this on a normal launch; a link skips the splash, and
    // AppRole.none would break the drawer, notification routing and the
    // language dialog.
    RoleNotifier.instance.setRole(AppRole.user);

    // `/open` carries no destination of its own — it just means "open the app".
    return location == UserAppRoutes.openApp ? UserAppRoutes.home : null;
  }

  static bool _isEntryPoint(String location) =>
      _entryPoints.contains(location) ||
      location.startsWith('/products/') ||
      location.startsWith('/store/products/');
}
