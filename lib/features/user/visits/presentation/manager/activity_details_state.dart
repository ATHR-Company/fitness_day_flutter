import 'package:fitness_day/features/user/visits/data/models/activity_details_model.dart';

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
  const ActivityDetailsFailure(this.message);
}
