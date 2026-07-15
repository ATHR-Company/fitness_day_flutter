import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_assessment_history_model.dart';
import 'package:fitness_day/features/specialist/visits/domain/usecases/get_assessment_history_usecase.dart';
import 'visits_state.dart';

class VisitsCubit extends Cubit<VisitsState> {
  final GetAssessmentHistoryUseCase _getAssessmentHistoryUseCase;

  int _currentPage = 1;
  static const int _limit = 10;
  final List<SpecialistAssessmentHistoryItemModel> _allVisits = [];
  bool _hasReachedMax = false;
  String _currentType = 'UPCOMING';
  String? _currentSearch;

  VisitsCubit(this._getAssessmentHistoryUseCase) : super(const VisitsInitial());

  Future<void> getVisits({
    required String type,
    bool isRefresh = false,
    String? search,
  }) async {
    _currentType = type;
    _currentSearch = search;

    if (isRefresh || search != null) {
      _currentPage = 1;
      _allVisits.clear();
      _hasReachedMax = false;
    }

    emit(const VisitsLoading());

    final result = await _getAssessmentHistoryUseCase(
      type: _currentType,
      page: _currentPage,
      limit: _limit,
      search: _currentSearch,
    );

    switch (result) {
      case Success(:final data):
        _allVisits.addAll(data.data);
        _hasReachedMax = _allVisits.length >= data.totalCount || data.data.isEmpty;
        emit(VisitsSuccess(
          visits: List.from(_allVisits),
          hasReachedMax: _hasReachedMax,
        ));
      case FailureResult(:final failure):
        emit(VisitsFailure(failure.message));
    }
  }

  Future<void> loadMoreVisits() async {
    if (state is VisitsLoading || state is VisitsLoadingMore || _hasReachedMax) {
      return;
    }

    emit(VisitsLoadingMore(List.from(_allVisits)));

    _currentPage++;

    final result = await _getAssessmentHistoryUseCase(
      type: _currentType,
      page: _currentPage,
      limit: _limit,
      search: _currentSearch,
    );

    switch (result) {
      case Success(:final data):
        if (data.data.isEmpty) {
          _hasReachedMax = true;
        } else {
          _allVisits.addAll(data.data);
          _hasReachedMax = _allVisits.length >= data.totalCount;
        }
        emit(VisitsSuccess(
          visits: List.from(_allVisits),
          hasReachedMax: _hasReachedMax,
        ));
      case FailureResult():
        _currentPage--; // roll back
        emit(VisitsSuccess(
          visits: List.from(_allVisits),
          hasReachedMax: _hasReachedMax,
        ));
    }
  }
}
