/// The API reports duration in **fractional** minutes (`0.9` for a 54-second
/// walk). The screen counts in seconds so short sessions aren't floored to zero.
int apiDurationSeconds(double? minutes) => ((minutes ?? 0) * 60).round();
