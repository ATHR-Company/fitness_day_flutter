import 'package:get_storage/get_storage.dart';
import 'package:fitness_day/core/models/user_model.dart';

abstract class AppCache {
  Future<void> saveIsLoggedIn(bool isLoggedIn);
  bool isLoggedIn();
  Future<void> saveHasSeenOnboarding(bool hasSeenOnboarding);
  bool hasSeenOnboarding();
  Future<void> saveUser(UserModel user);
  UserModel getUser();
  Future<void> deleteUser();
  Future<void> saveAssessmentId(String assessmentId);
  String? getAssessmentId();
  Future<void> saveUserType(String userType);
  String getUserType();
  Future<void> saveCompletionStatus({
    required bool personalData,
    required bool survey,
  });
  bool isPersonalDataComplete();
  bool isSurveyComplete();
  Future<void> clear();
}

class AppCacheImpl implements AppCache {
  final GetStorage _storage;

  AppCacheImpl(this._storage);

  static const _isLoggedInKey = 'is_logged_in';
  static const _hasSeenOnboardingKey = 'has_seen_onboarding';
  static const _userKey = 'cached_user_profile';
  static const _assessmentIdKey = 'assessment_id';
  static const _userTypeKey = 'user_type';
  static const _personalDataCompleteKey = 'is_personal_data_complete';
  static const _surveyCompleteKey = 'is_survey_complete';

  @override
  Future<void> saveIsLoggedIn(bool isLoggedIn) async {
    await _storage.write(_isLoggedInKey, isLoggedIn);
  }

  @override
  bool isLoggedIn() {
    return _storage.read(_isLoggedInKey) ?? false;
  }

  @override
  Future<void> saveUserType(String userType) async {
    await _storage.write(_userTypeKey, userType);
  }

  @override
  String getUserType() {
    return _storage.read(_userTypeKey) ?? 'user';
  }

  @override
  Future<void> saveCompletionStatus({
    required bool personalData,
    required bool survey,
  }) async {
    await _storage.write(_personalDataCompleteKey, personalData);
    await _storage.write(_surveyCompleteKey, survey);
  }

  // Defaults to `true` so users cached before this flag existed (and any
  // unknown state) are treated as complete and routed to home, never falsely
  // redirected into onboarding.
  @override
  bool isPersonalDataComplete() {
    return _storage.read(_personalDataCompleteKey) ?? true;
  }

  @override
  bool isSurveyComplete() {
    return _storage.read(_surveyCompleteKey) ?? true;
  }

  @override
  Future<void> saveHasSeenOnboarding(bool hasSeenOnboarding) async {
    await _storage.write(_hasSeenOnboardingKey, hasSeenOnboarding);
  }

  @override
  bool hasSeenOnboarding() {
    return _storage.read(_hasSeenOnboardingKey) ?? false;
  }

  @override
  Future<void> saveUser(UserModel user) async {
    await _storage.write(_userKey, user.toJson());
  }

  @override
  UserModel getUser() {
    final data = _storage.read(_userKey);
    if (data != null) {
      try {
        return UserModel.fromJson(Map<String, dynamic>.from(data));
      } catch (_) {
        // Fallback to default user
      }
    }
    // Return default user with initial mock data fields
    return const UserModel(
      name: 'رنا محمد',
      email: 'rana mohamed@gmail.com',
      phone: '99567890211',
      weight: 57.8,
      height: 167.0,
      goal: 'login.goal_gain',
      gender: 'female',
      birthDate: '2000-01-01',
    );
  }

  @override
  Future<void> deleteUser() async {
    await _storage.remove(_userKey);
  }

  @override
  Future<void> saveAssessmentId(String assessmentId) async {
    await _storage.write(_assessmentIdKey, assessmentId);
  }

  @override
  String? getAssessmentId() {
    return _storage.read(_assessmentIdKey);
  }

  @override
  Future<void> clear() async {
    await _storage.erase();
  }
}
