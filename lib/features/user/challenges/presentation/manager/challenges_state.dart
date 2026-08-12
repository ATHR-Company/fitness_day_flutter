import 'package:fitness_day/core/errors/app_error.dart';
import 'package:fitness_day/features/user/challenges/data/datasources/challenges_remote_datasource.dart';
import 'package:fitness_day/features/user/challenges/data/models/challenge_model.dart';

sealed class ChallengesState {
  const ChallengesState();
}

class ChallengesInitial extends ChallengesState {
  const ChallengesInitial();
}

class ChallengesLoading extends ChallengesState {
  const ChallengesLoading();
}

class ChallengesLoaded extends ChallengesState {
  final List<ChallengeModel> challenges;

  /// Null means "everything not finished yet" — active plus upcoming, which is
  /// what the screen opens on.
  final ChallengeStatusFilter? status;

  /// True for the "تحدياتي" tab.
  final bool onlyJoined;

  final int page;
  final int totalPages;
  final bool isLoadingMore;

  /// Id of the challenge whose join/leave is in flight, so one card can show a
  /// spinner without the whole list going blank.
  final String? busyChallengeId;

  const ChallengesLoaded({
    required this.challenges,
    this.status,
    this.onlyJoined = false,
    this.page = 1,
    this.totalPages = 1,
    this.isLoadingMore = false,
    this.busyChallengeId,
  });

  bool get hasMore => page < totalPages;

  ChallengesLoaded copyWith({
    List<ChallengeModel>? challenges,
    ChallengeStatusFilter? status,
    bool clearStatus = false,
    bool? onlyJoined,
    int? page,
    int? totalPages,
    bool? isLoadingMore,
    String? busyChallengeId,
    bool clearBusy = false,
  }) {
    return ChallengesLoaded(
      challenges: challenges ?? this.challenges,
      status: clearStatus ? null : (status ?? this.status),
      onlyJoined: onlyJoined ?? this.onlyJoined,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      busyChallengeId: clearBusy ? null : (busyChallengeId ?? this.busyChallengeId),
    );
  }
}

class ChallengesError extends ChallengesState {
  final String message;
  final AppError? error;
  const ChallengesError(this.message, {this.error});
}
