import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fitness_day/core/errors/app_error.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/challenges/data/models/challenge_model.dart';
import 'package:fitness_day/features/user/challenges/domain/usecases/challenges_usecases.dart';

sealed class ChallengeDetailsState {
  const ChallengeDetailsState();
}

class ChallengeDetailsLoading extends ChallengeDetailsState {
  const ChallengeDetailsLoading();
}

class ChallengeDetailsLoaded extends ChallengeDetailsState {
  final ChallengeModel challenge;

  /// A join or leave is in flight — the button shows a spinner while the rest
  /// of the sheet stays readable.
  final bool isBusy;

  const ChallengeDetailsLoaded(this.challenge, {this.isBusy = false});

  ChallengeDetailsLoaded copyWith({ChallengeModel? challenge, bool? isBusy}) {
    return ChallengeDetailsLoaded(
      challenge ?? this.challenge,
      isBusy: isBusy ?? this.isBusy,
    );
  }
}

class ChallengeDetailsError extends ChallengeDetailsState {
  final String message;
  final AppError? error;
  const ChallengeDetailsError(this.message, {this.error});
}

/// The details sheet: description, rules, progress, and the join/leave button.
class ChallengeDetailsCubit extends Cubit<ChallengeDetailsState> {
  final GetChallengeDetailsUseCase _getChallengeDetailsUseCase;
  final JoinChallengeUseCase _joinChallengeUseCase;
  final LeaveChallengeUseCase _leaveChallengeUseCase;

  ChallengeDetailsCubit({
    required GetChallengeDetailsUseCase getChallengeDetailsUseCase,
    required JoinChallengeUseCase joinChallengeUseCase,
    required LeaveChallengeUseCase leaveChallengeUseCase,
  })  : _getChallengeDetailsUseCase = getChallengeDetailsUseCase,
        _joinChallengeUseCase = joinChallengeUseCase,
        _leaveChallengeUseCase = leaveChallengeUseCase,
        super(const ChallengeDetailsLoading());

  late String _challengeId;

  /// [seed] is the card the sheet was opened from. Showing it immediately means
  /// the sheet never opens blank; the fetch then fills in the rules, which only
  /// the details endpoint returns.
  Future<void> load(String challengeId, {ChallengeModel? seed}) async {
    _challengeId = challengeId;
    if (seed != null) emit(ChallengeDetailsLoaded(seed));

    final result = await _getChallengeDetailsUseCase(challengeId);
    switch (result) {
      case Success(:final data):
        emit(ChallengeDetailsLoaded(data));
      case FailureResult(:final failure):
        // A seeded sheet keeps what it is showing — the card's data is still
        // true, it just has no rules tab yet.
        if (state is ChallengeDetailsLoaded) return;
        emit(ChallengeDetailsError(
          failure.message,
          error: AppError.from(failure),
        ));
    }
  }

  /// Returns `(success, message, challenge)`. The challenge is the server's
  /// own object — including the backfilled progress, which is often non-zero.
  Future<(bool, String, ChallengeModel?)> join() async {
    final current = state;
    if (current is! ChallengeDetailsLoaded || current.isBusy) {
      return (false, '', null);
    }

    emit(current.copyWith(isBusy: true));
    final result = await _joinChallengeUseCase(_challengeId);

    switch (result) {
      case Success(:final data):
        emit(ChallengeDetailsLoaded(data));
        return (true, '', data);
      case FailureResult(:final failure):
        emit(current.copyWith(isBusy: false));
        return (false, failure.message, null);
    }
  }

  Future<(bool, String)> leave() async {
    final current = state;
    if (current is! ChallengeDetailsLoaded || current.isBusy) {
      return (false, '');
    }

    emit(current.copyWith(isBusy: true));
    final result = await _leaveChallengeUseCase(_challengeId);

    switch (result) {
      case Success():
        // Refetched rather than patched: participantsCount and status are the
        // server's to state, and guessing them here would drift.
        await load(_challengeId);
        return (true, '');
      case FailureResult(:final failure):
        emit(current.copyWith(isBusy: false));
        return (false, failure.message);
    }
  }
}
