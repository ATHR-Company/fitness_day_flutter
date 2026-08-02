import 'package:fitness_day/features/user/visits/data/models/activity_details_model.dart';
import 'package:fitness_day/core/errors/app_error.dart';

sealed class ActivityDetailsState {
  const ActivityDetailsState();
}

class ActivityDetailsInitial extends ActivityDetailsState {
  const ActivityDetailsInitial();
}

class ActivityDetailsLoading extends ActivityDetailsState {
  const ActivityDetailsLoading();
}

class ActivityDetailsSuccess extends ActivityDetailsState {
  final ActivityDetailsData data;
  const ActivityDetailsSuccess(this.data);
}

class ActivityDetailsFailure extends ActivityDetailsState {
  final String message;

  /// Typed form of the failure, so the screen can decide between a
  /// full-screen retry and a message. Null on states not yet migrated.
  final AppError? error;
  const ActivityDetailsFailure(this.message, {this.error});
}
