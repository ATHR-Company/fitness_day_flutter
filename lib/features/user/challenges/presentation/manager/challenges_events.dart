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
/// [challenges] is **every** live joined challenge as the server reported it,
/// not only the ones that moved, so a listener redraws its list wholesale
/// instead of patching entries.
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
