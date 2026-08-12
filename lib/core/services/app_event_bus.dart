import 'dart:async';

/// In-app broadcast of "something the server owns just changed".
///
/// The problem it solves: the same item — a meal, a workout, an activity, an
/// article — is rendered on several screens at once, but it is *edited* on a
/// detail screen pushed on top of them. When that screen pops, every copy
/// behind it is stale.
///
/// Refetching the list was the previous answer, and it costs a request, a
/// spinner, and the scroll position, all to move one number. Worse, it only
/// fixed the screen that did the pushing: opening a meal from today-tasks left
/// the home screen underneath it stale regardless.
///
/// A broadcast stream fixes every live listener at once and costs nothing —
/// every value published here was already paid for by a request the detail
/// screen had to make anyway (the completion PATCH, the activity GET, the
/// article GET). Nothing on this bus is guessed locally; publishers only
/// forward what the server just confirmed, so a patched card cannot drift away
/// from the truth.
///
/// See `docs/live_update_event_bus.md` for how to add a new event.
/// Open, not `sealed`, on purpose.
///
/// Sealing would force every event type to live in this file, and `core` would
/// then have to import the models of whichever feature published them — a
/// feature-to-core dependency inverted. Features declare their own events
/// beside the code that raises them; the ones below are here only because they
/// are shared by several.
///
/// Nothing switches exhaustively over `AppEvent` — listeners match the specific
/// types they care about. [TaskProgressEvent] *is* sealed, and the exhaustive
/// switches are over that.
abstract class AppEvent {}

// ─── Daily-task events ───────────────────────────────────────────────────────

/// A meal / workout / activity card changed.
sealed class TaskProgressEvent extends AppEvent {
  /// Both are matched before a patch is applied — a listener showing day 3 must
  /// ignore an event for day 4, and a stale assessment must never patch a
  /// current one.
  final String assessmentId;
  final int dayNumber;

  TaskProgressEvent({
    required this.assessmentId,
    required this.dayNumber,
  });

  /// Id of the single card this event addresses. Listeners match it against
  /// `TaskData.taskId`.
  String get taskId;

  /// Whether the item now counts as done, as the server reported it.
  bool get isCompleted;
}

/// Hydration / walking / running progress, as returned by the activity details
/// and hydration endpoints.
class ActivityProgressChanged extends TaskProgressEvent {
  final String activityId;
  final double currentProgress;
  final double goal;
  @override
  final bool isCompleted;

  ActivityProgressChanged({
    required super.assessmentId,
    required super.dayNumber,
    required this.activityId,
    required this.currentProgress,
    required this.goal,
    required this.isCompleted,
  });

  @override
  String get taskId => activityId;
}

/// A meal was ticked or un-ticked on the meal details screen.
class MealProgressChanged extends TaskProgressEvent {
  final String mealId;
  @override
  final bool isCompleted;

  MealProgressChanged({
    required super.assessmentId,
    required super.dayNumber,
    required this.mealId,
    required this.isCompleted,
  });

  @override
  String get taskId => mealId;
}

/// A workout set was completed. [completedSets] / [totalSets] are what the
/// card's counter shows, so both travel with the event.
class WorkoutProgressChanged extends TaskProgressEvent {
  final String workoutItemId;
  final int completedSets;
  final int totalSets;
  @override
  final bool isCompleted;

  WorkoutProgressChanged({
    required super.assessmentId,
    required super.dayNumber,
    required this.workoutItemId,
    required this.completedSets,
    required this.totalSets,
    required this.isCompleted,
  });

  @override
  String get taskId => workoutItemId;
}

// ─── Article events ──────────────────────────────────────────────────────────

/// An article's view count or saved flag changed.
///
/// Two things move it, and they move different fields:
///  - opening the details screen, which is what *increments* the view count
///    server-side, so the GET's response is the only place the new number
///    exists;
///  - tapping the bookmark, anywhere it appears.
///
/// Both fields are nullable so each publisher reports only what it actually
/// learned — a bookmark tap says nothing about the view count, and writing a
/// stale one back would undo a fresher reading.
///
/// Deliberately carries ids and primitives, never a feature entity: this file
/// lives in `core/`, and importing `ArticleData` from `features/` would point a
/// dependency the wrong way through the layers. A listener that needs the whole
/// article — the saved list, when an article it has never seen gets
/// bookmarked — refetches silently instead.
class ArticleChanged extends AppEvent {
  final String articleId;
  final int? views;
  final bool? isSaved;

  ArticleChanged({
    required this.articleId,
    this.views,
    this.isSaved,
  });
}

// ─── The bus ─────────────────────────────────────────────────────────────────

/// App-wide singleton — registered in the DI container.
class AppEventBus {
  /// Broadcast, because several screens are listening whenever one is pushed on
  /// top of another; a single-subscription controller would throw on the second
  /// listener.
  final StreamController<AppEvent> _controller =
      StreamController<AppEvent>.broadcast();

  Stream<AppEvent> get stream => _controller.stream;

  void publish(AppEvent event) {
    if (_controller.isClosed) return;
    _controller.add(event);
  }

  /// Only ever called if the container itself is torn down; the bus outlives
  /// every screen by design.
  Future<void> dispose() => _controller.close();
}
