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
  Future<void> clear();
}

class AppCacheImpl implements AppCache {
  final GetStorage _storage;

  AppCacheImpl(this._storage);

  static const _isLoggedInKey = 'is_logged_in';
  static const _hasSeenOnboardingKey = 'has_seen_onboarding';
  static const _userKey = 'cached_user_profile';

  @override
  Future<void> saveIsLoggedIn(bool isLoggedIn) async {
    await _storage.write(_isLoggedInKey, isLoggedIn);
  }

  @override
  bool isLoggedIn() {
    return _storage.read(_isLoggedInKey) ?? false;
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
  Future<void> clear() async {
    await _storage.erase();
  }
}
