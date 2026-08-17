import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fitness_day/core/errors/app_error.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/challenges/data/datasources/challenges_remote_datasource.dart';
import 'package:fitness_day/features/user/challenges/data/models/challenge_model.dart';
import 'package:fitness_day/features/user/challenges/domain/usecases/challenges_usecases.dart';
import 'package:fitness_day/features/user/challenges/presentation/manager/challenges_state.dart';

/// The challenges list and its tabs.
class ChallengesCubit extends Cubit<ChallengesState> {
  final GetChallengesUseCase _getChallengesUseCase;
  final JoinChallengeUseCase _joinChallengeUseCase;
  final LeaveChallengeUseCase _leaveChallengeUseCase;

  ChallengesCubit({
    required GetChallengesUseCase getChallengesUseCase,
    required JoinChallengeUseCase joinChallengeUseCase,
    required LeaveChallengeUseCase leaveChallengeUseCase,
  })  : _getChallengesUseCase = getChallengesUseCase,
        _joinChallengeUseCase = joinChallengeUseCase,
        _leaveChallengeUseCase = leaveChallengeUseCase,
        super(const ChallengesInitial());

  static const int _kPageSize = 10;

  /// [status] null asks for everything not finished yet — the screen's default.
  Future<void> load({
    ChallengeStatusFilter? status,
    bool onlyJoined = false,
  }) async {
    emit(const ChallengesLoading());

    final result = await _getChallengesUseCase(
      status: status,
      // `false` would ask for challenges the user has *not* joined, which is a
      // different question from "don't filter" — so it is omitted entirely.
      joined: onlyJoined ? true : null,
      page: 1,
      limit: _kPageSize,
    );

    switch (result) {
      case Success(:final data):
        emit(ChallengesLoaded(
          challenges: data.challenges,
          status: status,
          onlyJoined: onlyJoined,
          page: data.page,
          totalPages: data.totalPages,
        ));
      case FailureResult(:final failure):
        emit(ChallengesError(failure.message, error: AppError.from(failure)));
    }
  }

  Future<void> loadNextPage() async {
    final current = state;
    if (current is! ChallengesLoaded) return;
    if (current.isLoadingMore || !current.hasMore) return;

    emit(current.copyWith(isLoadingMore: true));

    final result = await _getChallengesUseCase(
      status: current.status,
      joined: current.onlyJoined ? true : null,
      page: current.page + 1,
      limit: _kPageSize,
    );

    final latest = state;
    if (latest is! ChallengesLoaded) return;

    switch (result) {
      case Success(:final data):
        emit(latest.copyWith(
          challenges: [...latest.challenges, ...data.challenges],
          page: data.page,
          totalPages: data.totalPages,
          isLoadingMore: false,
        ));
      case FailureResult():
        // The page the user is reading stays; only the spinner goes. A failed
        // *next* page is not worth replacing good content with an error.
        emit(latest.copyWith(isLoadingMore: false));
    }
  }

  /// Joins, then patches the single card from the response.
  ///
  /// The reply is the full details object with `isJoined` and
  /// `participantsCount` already updated, so there is nothing to refetch — and
  /// its `progress` is frequently non-zero, because joining backfills whatever
  /// the ledger already holds for the elapsed days. Overwriting it with 0 here
  /// would throw that away.
  Future<(bool, String)> join(String challengeId) async {
    final current = state;
    if (current is! ChallengesLoaded) return (false, '');

    emit(current.copyWith(busyChallengeId: challengeId));
    final result = await _joinChallengeUseCase(challengeId);

    final latest = state;
    if (latest is! ChallengesLoaded) return (false, '');

    switch (result) {
      case Success(:final data):
        emit(latest.copyWith(
          challenges: _replace(latest.challenges, data),
          clearBusy: true,
        ));
        return (true, '');
      case FailureResult(:final failure):
        emit(latest.copyWith(clearBusy: true));
        return (false, failure.message);
    }
  }

  /// Leaves, discarding progress — the enrolment row is deleted outright, so
  /// re-joining later starts over. Worth confirming before calling.
  Future<(bool, String)> leave(String challengeId) async {
    final current = state;
    if (current is! ChallengesLoaded) return (false, '');

    emit(current.copyWith(busyChallengeId: challengeId));
    final result = await _leaveChallengeUseCase(challengeId);

    final latest = state;
    if (latest is! ChallengesLoaded) return (false, '');

    switch (result) {
      case Success():
        // The "my challenges" tab is a list of joined ones, so a leave removes
        // the row; elsewhere the card stays and drops back to 0%.
        final List<ChallengeModel> next = latest.onlyJoined
            ? latest.challenges.where((c) => c.id != challengeId).toList()
            : _resetLocally(latest.challenges, challengeId);
        emit(latest.copyWith(challenges: next, clearBusy: true));
        return (true, '');
      case FailureResult(:final failure):
        emit(latest.copyWith(clearBusy: true));
        return (false, failure.message);
    }
  }

  /// Moves the rings from a sync response.
  ///
  /// Each entry is patched onto the card it belongs to rather than replacing
  /// it: a sync reports progress, not a challenge record, so it has no
  /// `isJoined`, dates or participant count to give. Replacing wholesale
  /// dropped a joined challenge out of the active section on every sync.
  void applyLedgerUpdate(List<ChallengeModel> fresh) {
    final current = state;
    if (current is! ChallengesLoaded || fresh.isEmpty) return;

    final byId = {for (final c in fresh) c.id: c};
    emit(current.copyWith(
      challenges: [
        for (final c in current.challenges)
          byId[c.id] == null ? c : c.withLedgerProgress(byId[c.id]!),
      ],
    ));
  }

  List<ChallengeModel> _replace(
    List<ChallengeModel> list,
    ChallengeModel updated,
  ) {
    return [
      for (final c in list) c.id == updated.id ? updated : c,
    ];
  }

  /// Local mirror of what the server did on leave: no enrolment, no progress.
  /// The counts come back exact on the next fetch.
  List<ChallengeModel> _resetLocally(
    List<ChallengeModel> list,
    String challengeId,
  ) {
    return [
      for (final c in list)
        if (c.id != challengeId)
          c
        else
          ChallengeModel(
            id: c.id,
            name: c.name,
            description: c.description,
            image: c.image,
            metric: c.metric,
            unit: c.unit,
            goal: c.goal,
            startDate: c.startDate,
            endDate: c.endDate,
            status: c.status,
            participantsCount:
                c.participantsCount > 0 ? c.participantsCount - 1 : 0,
            isJoined: false,
            progress: 0,
            progressPercentage: 0,
            isCompleted: false,
            rules: c.rules,
          ),
    ];
  }
}
