/// Server-driven state of the visit's start/finish button, mirrors backend's
/// `AssessmentCurrentState` enum.
enum AssessmentCurrentState {
  /// Specialist hasn't started the assessment yet — initial state.
  notStarted('NOT_STARTED'),

  /// Started, but the plan data is still incomplete — specialist is filling it in.
  inProgress('IN_PROGRESS'),

  /// Started and the plan data is complete — specialist can finish the assessment.
  readyToFinish('READY_TO_FINISH'),

  /// Finished — final state; the specialist can only edit from here.
  completed('COMPLETED');

  final String value;

  const AssessmentCurrentState(this.value);

  /// Returns null when [value] is missing or unrecognized — callers must not
  /// assume NOT_STARTED in that case, since that would hide the real screen
  /// (and everything in it, e.g. the goal card) for visits the backend just
  /// hasn't labeled yet. Fall back to another signal (e.g. isStarted) instead.
  static AssessmentCurrentState? fromJson(String? value) {
    if (value == null) return null;
    for (final e in AssessmentCurrentState.values) {
      if (e.value == value) return e;
    }
    return null;
  }
}
