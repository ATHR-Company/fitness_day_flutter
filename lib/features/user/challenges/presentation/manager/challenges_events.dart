import 'package:fitness_day/core/services/app_event_bus.dart';
import 'package:fitness_day/features/user/challenges/data/models/achievement_model.dart';
import 'package:fitness_day/features/user/challenges/data/models/activity_sync_models.dart';
import 'package:fitness_day/features/user/challenges/data/models/challenge_model.dart';

/// Events this feature puts on [AppEventBus].
///
/// They live here rather than in `core` so that `core` does not have to import
/// the models of a feature — see the note on [AppEvent].

/// The challenges ledger moved. Published after every accepted `/activity-sync`,
/// including a replay: nothing was applied there, but the totals it reports are
/// still current.
///
/// [challenges] carries every live joined challenge the sync touched — but as
/// *ledger* entries, which is not the same shape as a challenge record. They
/// hold `challengeId`, `name`, `metric`, `unit`, `goal` and this user's
/// progress, and nothing else: no `isJoined`, no dates, no `participantsCount`,
/// no `status`.
///
/// So a listener must merge them with [ChallengeModel.withLedgerProgress]
/// rather than swap them in. Assigning one wholesale silently sets `isJoined`
/// to false and the dates to null, which moved a joined challenge into the
/// "suggested" section after every session stop.
class ActivityLedgerChanged extends AppEvent {
  final ActivityTotalsModel totals;
  final List<ChallengeModel> challenges;

  /// How many challenges crossed their goal on that sync — the "لقد أكملت
  /// التحدي" moment. Always zero on a replay.
  final int completedChallenges;

  ActivityLedgerChanged({
    required this.totals,
    required this.challenges,
    this.completedChallenges = 0,
  });
}

/// Badges unlocked by a single sync, and only by it.
///
/// The backend does the diffing, so this list is exactly what deserves a
/// celebration — a listener never compares against what it already knew. It can
/// arrive while the user is on any screen, which is why it is broadcast rather
/// than returned to whoever triggered the sync.
class AchievementsUnlocked extends AppEvent {
  final List<AchievementModel> achievements;

  AchievementsUnlocked(this.achievements);
}
