import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/features/user/visits/presentation/manager/activity_details_cubit.dart';
import 'package:fitness_day/features/user/user_home/presentation/screens/activity_type.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/activity/steps_details_loader.dart';

// Callers open this screen with an [ActivityType]; re-exported so they keep
// getting it from here instead of having to import a second file.
export 'package:fitness_day/features/user/user_home/presentation/screens/activity_type.dart';

/// The screen shows `goal` and `currentProgress` exactly as the API sends them,
/// with no rescaling.
///
/// For running those are now **kilometres** (`goal: 2`, `currentProgress: 0.14`,
/// `unit: "km"`) — the backend used to report metres, and the screen converted
/// the running cubit's live kilometres up by 1000 to match. Against km figures
/// that conversion turned a 130 m run into "130.14 / 2", which is what made the
/// display jump the moment a session started contributing. The live distance is
/// already in kilometres, so it is layered on as-is.
///
/// Note the sync endpoints are unchanged: `deltaDistance` is still posted in
/// metres. Only the read side moved to kilometres.

// ─────────────────────────────────────────────────────────────────────────────
// Entry point — loads activity details from API, then injects goals into cubit
// ─────────────────────────────────────────────────────────────────────────────

class StepsDetailsScreen extends StatelessWidget {
  final ActivityType type;
  final String assessmentId;
  final int dayNumber;
  final String activityId;

  const StepsDetailsScreen({
    super.key,
    this.type = ActivityType.walking,
    this.assessmentId = '',
    this.dayNumber = 1,
    this.activityId = '',
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ActivityDetailsCubit>()
        ..getActivityDetails(assessmentId, dayNumber, activityId),
      child: StepsDetailsLoader(
        type: type,
        assessmentId: assessmentId,
        dayNumber: dayNumber,
        activityId: activityId,
      ),
    );
  }
}
