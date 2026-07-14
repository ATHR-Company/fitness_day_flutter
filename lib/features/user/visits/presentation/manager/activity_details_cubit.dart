import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/core/constant/api_endpoints.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/network/api_service.dart';
import 'package:fitness_day/features/user/visits/domain/usecases/get_activity_details_usecase.dart';
import 'package:fitness_day/features/user/visits/data/models/activity_details_model.dart';
import 'activity_details_state.dart';

class ActivityDetailsCubit extends Cubit<ActivityDetailsState> {
  final GetActivityDetailsUseCase _getActivityDetailsUseCase;

  // Cached params for increase/decrease calls
  String _assessmentId = '';
  int _dayNumber = 1;
  String _activityId = '';

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
    _assessmentId = assessmentId;
    _dayNumber = dayNumber;
    _activityId = activityId;
    emit(const ActivityDetailsLoading());
    final result = await _getActivityDetailsUseCase(
        assessmentId, dayNumber, activityId,
        period: period);
    switch (result) {
      case Success(:final data):
        emit(ActivityDetailsSuccess(data.data));
      case FailureResult(:final failure):
        emit(ActivityDetailsFailure(failure.message));
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
    } catch (_) {
      // Keep current state on failure
    }
  }
}
