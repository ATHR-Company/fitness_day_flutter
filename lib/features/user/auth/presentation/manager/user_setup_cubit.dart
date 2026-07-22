import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/cache/app_cache.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/auth/data/models/user_lookups_model.dart';
import 'package:fitness_day/features/user/auth/data/models/complete_personal_data_models.dart';
import 'package:fitness_day/features/user/auth/data/models/submit_health_answers_models.dart';
import 'package:fitness_day/features/user/auth/domain/usecases/get_user_lookups_usecase.dart';
import 'package:fitness_day/features/user/auth/domain/usecases/complete_personal_data_usecase.dart';
import 'package:fitness_day/features/user/auth/domain/usecases/get_health_questions_usecase.dart';
import 'package:fitness_day/features/user/auth/domain/usecases/submit_health_answers_usecase.dart';
import 'user_setup_state.dart';

class UserSetupCubit extends Cubit<UserSetupState> {
  final GetUserLookupsUseCase _getUserLookupsUseCase;
  final CompletePersonalDataUseCase _completePersonalDataUseCase;
  final GetHealthQuestionsUseCase _getHealthQuestionsUseCase;
  final SubmitHealthAnswersUseCase _submitHealthAnswersUseCase;
  final AppCache _appCache;

  UserSetupCubit({
    required GetUserLookupsUseCase getUserLookupsUseCase,
    required CompletePersonalDataUseCase completePersonalDataUseCase,
    required GetHealthQuestionsUseCase getHealthQuestionsUseCase,
    required SubmitHealthAnswersUseCase submitHealthAnswersUseCase,
    required AppCache appCache,
  })  : _getUserLookupsUseCase = getUserLookupsUseCase,
        _completePersonalDataUseCase = completePersonalDataUseCase,
        _getHealthQuestionsUseCase = getHealthQuestionsUseCase,
        _submitHealthAnswersUseCase = submitHealthAnswersUseCase,
        _appCache = appCache,
        super(const UserSetupInitial());

  // Cached lookups
  List<LookupItem> _goals = [];
  List<LookupItem> _activityLevels = [];
  List<LookupItem> _branches = [];

  List<LookupItem> get goals => _goals;
  List<LookupItem> get activityLevels => _activityLevels;
  List<LookupItem> get branches => _branches;

  // Intermediate registration data
  String? fullName;
  String? gender;
  String? birthDate;
  double? height;
  double? weight;
  String? activityLevelId;
  String? goalId;
  String? branchId;
  
  String? dietType;
  int? dailyMeals;
  String? preferredFoods;
  String? dislikedFoods;
  String? foodAllergies;

  int? weeklyWorkouts;
  int? dailySteps;
  String? preferredExercises;
  double? dailyWorkoutHours;

  // Cached final report
  BodyReportModel? bodyReport;
  bool? isSubscribed;

  void savePersonalData({
    required String fullName,
    required String gender,
    required String birthDate,
    required double height,
    required double weight,
    required String activityLevelId,
    required String goalId,
    required String branchId,
  }) {
    this.fullName = fullName;
    this.gender = gender;
    this.birthDate = birthDate;
    this.height = height;
    this.weight = weight;
    this.activityLevelId = activityLevelId;
    this.goalId = goalId;
    this.branchId = branchId;
  }

  void saveDietData({
    required String dietType,
    required int dailyMeals,
    required String preferredFoods,
    required String dislikedFoods,
    required String foodAllergies,
  }) {
    this.dietType = dietType;
    this.dailyMeals = dailyMeals;
    this.preferredFoods = preferredFoods;
    this.dislikedFoods = dislikedFoods;
    this.foodAllergies = foodAllergies;
  }

  void saveFitnessData({
    required int weeklyWorkouts,
    required int dailySteps,
    required String preferredExercises,
    required double dailyWorkoutHours,
  }) {
    this.weeklyWorkouts = weeklyWorkouts;
    this.dailySteps = dailySteps;
    this.preferredExercises = preferredExercises;
    this.dailyWorkoutHours = dailyWorkoutHours;
  }

  Future<void> fetchLookups() async {
    emit(const UserSetupLoading());
    final result = await _getUserLookupsUseCase();
    switch (result) {
      case Success(:final data):
        _goals = data.goals;
        _activityLevels = data.activityLevels;
        _branches = data.branches;
        emit(UserLookupsLoadSuccess(
          goals: data.goals,
          activityLevels: data.activityLevels,
          branches: data.branches,
        ));
      case FailureResult(:final failure):
        emit(UserSetupFailure(failure.message));
    }
  }

  Future<void> submitPersonalData() async {
    emit(const UserSetupLoading());
    final request = CompletePersonalDataRequest(
      fullName: fullName ?? '',
      gender: gender ?? 'male',
      birthDate: birthDate ?? '',
      height: height ?? 0,
      weight: weight ?? 0,
      activityLevel: activityLevelId ?? '',
      goal: goalId ?? '',
      branch: branchId ?? '',
      dietType: dietType ?? 'MIXED',
      dailyMeals: dailyMeals ?? 3,
      preferredFoods: preferredFoods ?? '',
      dislikedFoods: dislikedFoods ?? '',
      foodAllergies: foodAllergies ?? '',
      weeklyWorkouts: weeklyWorkouts ?? 3,
      dailySteps: dailySteps ?? 8000,
      preferredExercises: preferredExercises ?? '',
      dailyWorkoutHours: dailyWorkoutHours ?? 1.0,
    );

    final result = await _completePersonalDataUseCase(request);
    switch (result) {
      case Success(:final data):
        final cached = _appCache.getUser();
        final updated = cached.copyWith(
          name: fullName,
          gender: gender,
          height: height,
          weight: weight,
          goal: goalId,
          birthDate: birthDate,
        );
        await _appCache.saveUser(updated);
        // Mark the session as logged in only once onboarding is fully done —
        // otherwise closing the app mid-signup should land back on role
        // selection, not resume straight to home.
        if (data.isPersonalDataComplete && data.isSurveyComplete) {
          await _appCache.saveIsLoggedIn(true);
        }
        emit(CompletePersonalDataSuccess(data.message));
      case FailureResult(:final failure):
        emit(UserSetupFailure(failure.message));
    }
  }

  Future<void> fetchHealthQuestions() async {
    emit(const UserSetupLoading());
    final result = await _getHealthQuestionsUseCase();
    switch (result) {
      case Success(:final data):
        emit(HealthQuestionsLoadSuccess(data.data));
      case FailureResult(:final failure):
        emit(UserSetupFailure(failure.message));
    }
  }

  Future<void> submitHealthAnswers(List<HealthAnswerItem> answers) async {
    emit(const UserSetupLoading());
    final request = SubmitHealthAnswersRequest(healthAnswers: answers);
    final result = await _submitHealthAnswersUseCase(request);
    switch (result) {
      case Success(:final data):
        bodyReport = data.bodyReport;
        isSubscribed = data.isSubscribed;
        if (data.isPersonalDataComplete && data.isSurveyComplete) {
          await _appCache.saveIsLoggedIn(true);
        }
        emit(SubmitHealthAnswersSuccess(
          bodyReport: data.bodyReport,
          isSubscribed: data.isSubscribed,
          message: data.message,
        ));
      case FailureResult(:final failure):
        emit(UserSetupFailure(failure.message));
    }
  }
}
