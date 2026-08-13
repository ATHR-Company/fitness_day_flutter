import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/core/constant/api_endpoints.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/network/api_service.dart';
import 'package:fitness_day/core/services/app_event_bus.dart';
import 'package:fitness_day/features/user/challenges/presentation/manager/activity_sync_service.dart';
import 'package:fitness_day/features/user/visits/domain/usecases/get_activity_details_usecase.dart';
import 'package:fitness_day/features/user/visits/data/models/activity_details_model.dart';
import 'activity_details_state.dart';
import 'package:fitness_day/core/errors/app_error.dart';

class ActivityDetailsCubit extends Cubit<ActivityDetailsState> {
  final GetActivityDetailsUseCase _getActivityDetailsUseCase;

  // Cached params for increase/decrease calls
  String _assessmentId = '';
  int _dayNumber = 1;
  String _activityId = '';

  /// Monotonic request counter. Rapid daily/weekly toggling fires overlapping
  /// GETs; without this the slower (older) response could land last and clobber
  /// the newer one, leaving the page showing data for the tab the user left.
  int _requestSeq = 0;

  ActivityDetailsCubit({
    required GetActivityDetailsUseCase getActivityDetailsUseCase,
  })  : _getActivityDetailsUseCase = getActivityDetailsUseCase,
        super(const ActivityDetailsInitial());

  // Expose cached params so the screen can re-fetch with a different period
  String get assessmentId => _assessmentId;
  int get dayNumber => _dayNumber;
  String get activityId => _activityId;

  Future<void> getActivityDetails(
      String assessmentId, int dayNumber, String activityId,
      {String period = 'daily'}) async {
    final int seq = ++_requestSeq;
    _assessmentId = assessmentId;
    _dayNumber = dayNumber;
    _activityId = activityId;
    emit(const ActivityDetailsLoading());
    final result = await _getActivityDetailsUseCase(
        assessmentId, dayNumber, activityId,
        period: period);
    // A newer toggle superseded this request while it was in flight — its
    // response is the authoritative one, so drop this stale result instead of
    // letting it overwrite the newer data.
    if (seq != _requestSeq) return;
    switch (result) {
      case Success(:final data):
        emit(ActivityDetailsSuccess(data.data));
        // Only the daily view describes today's card. The weekly/monthly tabs
        // return an aggregate over the period, and publishing that would put a
        // week's worth of steps on a card whose goal is a single day's.
        if (period == 'daily') _publishProgress(data.data);
      case FailureResult(:final failure):
        emit(ActivityDetailsFailure(failure.message, error: AppError.from(failure)));
    }
  }

  Future<void> increaseHydration({double amount = 0.25}) =>
      _updateHydration(increase: true, amount: amount);

  Future<void> decreaseHydration({double amount = 0.25}) =>
      _updateHydration(increase: false, amount: amount);

  Future<void> _updateHydration(
      {required bool increase, double amount = 0.25}) async {
    try {
      final api = getIt<ApiService>();
      final endpoint = increase
          ? ApiEndpoints.hydrationIncrease(_assessmentId, _dayNumber, _activityId)
          : ApiEndpoints.hydrationDecrease(_assessmentId, _dayNumber, _activityId);
      final response = await api.patch(endpoint, data: {'amount': amount});
      final data = ActivityDetailsResponseModel.fromJson(
          response.data as Map<String, dynamic>);
      emit(ActivityDetailsSuccess(data.data));
      _publishProgress(data.data);

      // Second destination, same number. `amount` is litres here and the ledger
      // takes millilitres; removing a glass sends it negative, which is the one
      // field allowed to be — server totals are floored at zero.
      //
      // Only after the plan PATCH succeeds: the catch below leaves the UI on
      // its previous figure, so a delta credited here would be water the user
      // was never shown as having logged.
      getIt<ActivitySyncService>().pushHydration(
        deltaWaterMl: (amount * 1000).round() * (increase ? 1 : -1),
      );
    } catch (_) {
      // Keep current state on failure
    }
  }

  /// Broadcasts the server's figure for this activity so the home and
  /// today-tasks cards behind this screen update without refetching.
  ///
  /// This cubit is the single hub every activity flows through — hydration
  /// increments land here, and the walking/running screens ask it to re-read
  /// after each sync — so one publish point covers all three types. Nothing
  /// extra is requested: every value here came from a response the screen had
  /// already made.
  void _publishProgress(ActivityDetailsData data) {
    getIt<AppEventBus>().publish(ActivityProgressChanged(
      // Falls back to the ids this cubit was called with: the details payload
      // omits them on some responses, and an empty assessmentId would fail the
      // listeners' match and silently drop the patch.
      assessmentId:
          data.assessmentId.isNotEmpty ? data.assessmentId : _assessmentId,
      dayNumber: data.dayNumber,
      activityId: data.activityId.isNotEmpty ? data.activityId : _activityId,
      currentProgress: data.currentProgress,
      goal: data.goal,
      isCompleted: data.isCompleted,
    ));
  }
}
