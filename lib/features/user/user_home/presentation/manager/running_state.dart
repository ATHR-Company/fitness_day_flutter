part of 'running_cubit.dart';

class RunningState extends Equatable {
  final bool isRunning;
  final bool sessionFinished;
  final bool permissionGranted;
  final double distanceKm;
  final int steps;
  final double caloriesKcal;
  final int elapsedSeconds;
  final double goalDistanceKm;

  const RunningState({
    this.isRunning = false,
    this.sessionFinished = false,
    this.permissionGranted = false,
    this.distanceKm = 0,
    this.steps = 0,
    this.caloriesKcal = 0,
    this.elapsedSeconds = 0,
    required this.goalDistanceKm,
  });

  double get progressPercent =>
      goalDistanceKm > 0 ? (distanceKm / goalDistanceKm).clamp(0.0, 1.0) : 0.0;

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

  /// Current pace (min/km). Returns '--:--' when no distance yet.
  String get pace {
    if (distanceKm <= 0 || elapsedSeconds <= 0) return '--:--';
    final double minPerKm = (elapsedSeconds / 60) / distanceKm;
    final int paceMin = minPerKm.floor();
    final int paceSec = ((minPerKm - paceMin) * 60).round();
    return '$paceMin:${paceSec.toString().padLeft(2, '0')}';
  }

  RunningState copyWith({
    bool? isRunning,
    bool? sessionFinished,
    bool? permissionGranted,
    double? distanceKm,
    int? steps,
    double? caloriesKcal,
    int? elapsedSeconds,
    double? goalDistanceKm,
  }) {
    return RunningState(
      isRunning: isRunning ?? this.isRunning,
      sessionFinished: sessionFinished ?? this.sessionFinished,
      permissionGranted: permissionGranted ?? this.permissionGranted,
      distanceKm: distanceKm ?? this.distanceKm,
      steps: steps ?? this.steps,
      caloriesKcal: caloriesKcal ?? this.caloriesKcal,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      goalDistanceKm: goalDistanceKm ?? this.goalDistanceKm,
    );
  }

  @override
  List<Object?> get props => [
        isRunning,
        sessionFinished,
        permissionGranted,
        distanceKm,
        steps,
        caloriesKcal,
        elapsedSeconds,
        goalDistanceKm,
      ];
}
