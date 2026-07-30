
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/features/user/visits/presentation/manager/activity_details_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/features/user/user_home/presentation/widgets/hydration/hydration_details_content.dart';

class HydrationDetailsScreen extends StatelessWidget {
  final String assessmentId;
  final int dayNumber;
  final String activityId;

  const HydrationDetailsScreen({
    super.key,
    required this.assessmentId,
    required this.dayNumber,
    required this.activityId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ActivityDetailsCubit>()
        ..getActivityDetails(assessmentId, dayNumber, activityId),
      child: const HydrationDetailsContent(),
    );
  }
}
