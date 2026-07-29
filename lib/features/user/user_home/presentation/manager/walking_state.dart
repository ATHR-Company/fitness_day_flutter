part of 'walking_cubit.dart';

enum HealthPermStatus { unknown, needsInstall, denied, granted }

class WalkingState extends Equatable {
  final int steps;
  final double distanceKm;
  final double caloriesKcal;

  /// Real stopwatch seconds since the session started, the same measure running
  /// uses. It replaced a steps ÷ 100 estimate, which drifted from the clock and
  /// gave the server nothing to credit the walk's duration with.
  final int elapsedSeconds;
  final double goalSteps;
  final double goalDistanceKm;
  final HealthPermStatus permissionStatus;
  final bool isLoading;

  /// True between the user pressing start and pressing stop. Nothing is read
  /// from the sensors or sent to the server while this is false.
  final bool isTracking;

  const WalkingState({
    this.steps = 0,
    this.distanceKm = 0,
    this.caloriesKcal = 0,
    this.elapsedSeconds = 0,
    required this.goalSteps,
    required this.goalDistanceKm,
    this.permissionStatus = HealthPermStatus.unknown,
    this.isLoading = true,
    this.isTracking = false,
  });

  double get progressPercent =>
      goalSteps > 0 ? (steps / goalSteps).clamp(0.0, 1.0) : 0.0;

  int get progressPercentInt => (progressPercent * 100).round();

  /// Formatted elapsed time: mm:ss or hh:mm:ss
  String get formattedTime {
    final int h = elapsedSeconds ~/ 3600;
    final int m = (elapsedSeconds % 3600) ~/ 60;
    final int s = elapsedSeconds % 60;
    final String mm = m.toString().padLeft(2, '0');
    final String ss = s.toString().padLeft(2, '0');
    if (h > 0) return '$h:$mm:$ss';
    return '$mm:$ss';
  }

  WalkingState copyWith({
    int? steps,
    double? distanceKm,
    double? caloriesKcal,
    int? elapsedSeconds,
    double? goalSteps,
    double? goalDistanceKm,
    HealthPermStatus? permissionStatus,
    bool? isLoading,
    bool? isTracking,
  }) {
    return WalkingState(
      steps: steps ?? this.steps,
      distanceKm: distanceKm ?? this.distanceKm,
      caloriesKcal: caloriesKcal ?? this.caloriesKcal,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      goalSteps: goalSteps ?? this.goalSteps,
      goalDistanceKm: goalDistanceKm ?? this.goalDistanceKm,
      permissionStatus: permissionStatus ?? this.permissionStatus,
      isLoading: isLoading ?? this.isLoading,
      isTracking: isTracking ?? this.isTracking,
    );
  }

  @override
  List<Object?> get props => [
        steps,
        distanceKm,
        caloriesKcal,
        elapsedSeconds,
        goalSteps,
        goalDistanceKm,
        permissionStatus,
        isLoading,
        isTracking,
      ];
}
