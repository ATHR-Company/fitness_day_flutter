import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/core/services/app_event_bus.dart';
import 'package:fitness_day/features/user/challenges/data/models/activity_sync_models.dart';
import 'package:fitness_day/features/user/challenges/domain/usecases/challenges_usecases.dart';
import 'package:fitness_day/features/user/challenges/presentation/manager/challenges_events.dart';

/// Feeds the challenges/achievements ledger.
///
/// This is the **second** destination for every delta the app produces. The
/// plan's own `POST /user-activities/*/sync` calls stay exactly as they are;
/// the same numbers are handed here as well, and neither total is computed
/// from the other. A user with no assessment reaches only this one.
///
/// A singleton, because it owns a retry queue: two instances would each hold
/// half the unsent deltas and neither could guarantee ordering.
class ActivitySyncService {
  final PushActivityUseCase _pushActivityUseCase;
  final GetDailyTotalsUseCase _getDailyTotalsUseCase;
  final AppEventBus _eventBus;

  ActivitySyncService({
    required PushActivityUseCase pushActivityUseCase,
    required GetDailyTotalsUseCase getDailyTotalsUseCase,
    required AppEventBus eventBus,
  })  : _pushActivityUseCase = pushActivityUseCase,
        _getDailyTotalsUseCase = getDailyTotalsUseCase,
        _eventBus = eventBus;

  static const Uuid _uuid = Uuid();

  /// Deltas built but not yet acknowledged, oldest first.
  ///
  /// A failed sync is never folded into the next payload — it is kept here with
  /// its original `syncId` and resent as-is. Merging two failed deltas into one
  /// would lose the idempotency key that stops a request which *did* land from
  /// being counted twice.
  final Queue<ActivitySyncRequestModel> _pending =
      Queue<ActivitySyncRequestModel>();

  /// Ceiling on the queue. Long enough to ride out a tunnel, short enough that
  /// a device offline for an hour doesn't hold a day of deltas in memory and
  /// then flood the server on reconnect.
  static const int _kMaxPending = 200;

  /// Serialises the whole queue. Two syncs in flight at once could arrive out
  /// of order, and the second's response would then describe a state the first
  /// has already moved past.
  Future<void>? _draining;

  /// Last totals the server reported, for whoever wants to redraw without
  /// asking again.
  ActivityTotalsModel? get lastTotals => _lastTotals;
  ActivityTotalsModel? _lastTotals;

  // ── Public API, one method per source ──────────────────────────────────────

  void pushWalking({
    required int deltaSteps,
    required double deltaDistanceMeters,
    required int durationSeconds,
  }) {
    if (deltaSteps <= 0 && deltaDistanceMeters <= 0 && durationSeconds <= 0) {
      return;
    }
    _enqueue(ActivitySyncRequestModel(
      source: ActivitySource.walking,
      syncId: _uuid.v4(),
      deltaSteps: deltaSteps,
      deltaDistanceMeters: deltaDistanceMeters,
      durationSeconds: durationSeconds,
    ));
  }

  void pushRunning({
    required double deltaDistanceMeters,
    required int durationSeconds,
  }) {
    // Steps are deliberately not sent for running — the backend reads them only
    // for walking and would drop them.
    if (deltaDistanceMeters <= 0 && durationSeconds <= 0) return;
    _enqueue(ActivitySyncRequestModel(
      source: ActivitySource.running,
      syncId: _uuid.v4(),
      deltaDistanceMeters: deltaDistanceMeters,
      durationSeconds: durationSeconds,
    ));
  }

  /// [deltaWaterMl] may be negative — that is how a mistakenly logged glass is
  /// taken back. Server-side totals are floored at zero.
  void pushHydration({required int deltaWaterMl}) {
    if (deltaWaterMl == 0) return;
    _enqueue(ActivitySyncRequestModel(
      source: ActivitySource.hydration,
      syncId: _uuid.v4(),
      deltaWaterMl: deltaWaterMl,
    ));
  }

  // ── Launch reconciliation ──────────────────────────────────────────────────

  /// Whether the day's stored totals have been read once this app session.
  ///
  /// Attempted once and then left alone whether or not it succeeded: nothing
  /// downstream depends on it, so a failure must not wedge the queue behind a
  /// retry loop.
  bool _primeAttempted = false;

  /// Reads `GET /activity-sync/daily` so [lastTotals] starts the session
  /// holding the server's figure rather than null.
  ///
  /// Run before the first sync of a session, as the contract asks. Note that
  /// this app does **not** need it to avoid double-counting: the deltas it
  /// sends are session-relative — each walking/running session starts its
  /// counters at zero and reports only what accrued since the previous push —
  /// so it never re-sends a cumulative daily reading in the first place, and a
  /// reinstall replays nothing. Kept because seeding the totals is still worth
  /// one request, and because an app that later switched to sending
  /// `today's total - what the server has` would need exactly this.
  Future<void> primeDailyTotals() async {
    _primeAttempted = true;
    final result = await _getDailyTotalsUseCase();
    switch (result) {
      case Success(:final data):
        _lastTotals = data;
        debugPrint(
          '[ActivitySync] 🔄 primed ${data.dayKey}: steps=${data.steps} '
          'water=${data.waterMl}ml',
        );
      case FailureResult(:final failure):
        debugPrint('[ActivitySync] ⚠️  prime failed: ${failure.message}');
    }
  }

  // ── Queue ──────────────────────────────────────────────────────────────────

  void _enqueue(ActivitySyncRequestModel request) {
    if (_pending.length >= _kMaxPending) {
      // Drop the oldest rather than the newest: recent progress is the part the
      // user is looking at, and the whole queue is best-effort anyway.
      final dropped = _pending.removeFirst();
      debugPrint(
        '[ActivitySync] ⚠️  queue full — dropped ${dropped.source.wireValue} '
        'delta ${dropped.syncId}',
      );
    }
    _pending.add(request);
    _drain();
  }

  void _drain() {
    _draining ??= _drainLoop().whenComplete(() => _draining = null);
  }

  Future<void> _drainLoop() async {
    // "Before the first sync of the session" — hooked here rather than at app
    // launch so it cannot be missed by a boot path that forgets to call it, and
    // so a user who never moves never pays for the request.
    if (!_primeAttempted) await primeDailyTotals();

    while (_pending.isNotEmpty) {
      final request = _pending.first;
      final result = await _pushActivityUseCase(request);

      switch (result) {
        case Success(:final data):
          _pending.removeFirst();
          _handleResult(data);
        case FailureResult(:final failure):
          // Left at the head of the queue with its syncId intact. The next
          // delta to arrive retries it; a request that actually reached the
          // server is recognised as a replay and applied once.
          debugPrint(
            '[ActivitySync] ❌ ${request.source.wireValue} failed: '
            '${failure.message} — keeping ${request.syncId} for retry',
          );
          return;
      }
    }
  }

  void _handleResult(ActivitySyncResultModel result) {
    _lastTotals = result.totals;

    // A replay applied nothing, so it can never carry new badges — the backend
    // guarantees the list is empty, and re-publishing would double-celebrate.
    if (result.replayed) {
      debugPrint('[ActivitySync] ↩️  replayed — totals refreshed only');
      _eventBus.publish(ActivityLedgerChanged(
        totals: result.totals,
        challenges: result.challenges,
      ));
      return;
    }

    debugPrint(
      '[ActivitySync] ✅ steps=${result.totals.steps} '
      'water=${result.totals.waterMl}ml '
      'challenges=${result.challenges.length} '
      'new badges=${result.newAchievements.length}',
    );

    _eventBus.publish(ActivityLedgerChanged(
      totals: result.totals,
      challenges: result.challenges,
      completedChallenges: result.completedChallenges,
    ));

    // Broadcast rather than returned: a sync runs while the user is on any
    // screen, so the celebration cannot be the caller's responsibility.
    if (result.newAchievements.isNotEmpty) {
      _eventBus.publish(AchievementsUnlocked(result.newAchievements));
    }
  }
}
