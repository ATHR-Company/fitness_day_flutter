part of 'walking_cubit.dart';

enum HealthPermStatus { unknown, needsInstall, denied, granted }

class WalkingState extends Equatable {
  final int steps;
  final double distanceKm;
  final double caloriesKcal;
  final int activeMinutes;
  final double goalSteps;
  final double goalDistanceKm;
  final HealthPermStatus permissionStatus;
  final bool isLoading;

  const WalkingState({
    this.steps = 0,
    this.distanceKm = 0,
    this.caloriesKcal = 0,
    this.activeMinutes = 0,
    required this.goalSteps,
    required this.goalDistanceKm,
    this.permissionStatus = HealthPermStatus.unknown,
    this.isLoading = true,
  });

  double get progressPercent =>
      goalSteps > 0 ? (steps / goalSteps).clamp(0.0, 1.0) : 0.0;

  int get progressPercentInt => (progressPercent * 100).round();

  WalkingState copyWith({
    int? steps,
    double? distanceKm,
    double? caloriesKcal,
    int? activeMinutes,
    double? goalSteps,
    double? goalDistanceKm,
    HealthPermStatus? permissionStatus,
    bool? isLoading,
  }) {
    return WalkingState(
      steps: steps ?? this.steps,
      distanceKm: distanceKm ?? this.distanceKm,
      caloriesKcal: caloriesKcal ?? this.caloriesKcal,
      activeMinutes: activeMinutes ?? this.activeMinutes,
      goalSteps: goalSteps ?? this.goalSteps,
      goalDistanceKm: goalDistanceKm ?? this.goalDistanceKm,
      permissionStatus: permissionStatus ?? this.permissionStatus,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
        steps,
        distanceKm,
        caloriesKcal,
        activeMinutes,
        goalSteps,
        goalDistanceKm,
        permissionStatus,
        isLoading,
      ];
}
