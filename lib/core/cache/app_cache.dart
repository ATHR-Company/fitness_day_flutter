import 'package:get_storage/get_storage.dart';

abstract class AppCache {
  Future<void> saveIsLoggedIn(bool isLoggedIn);
  bool isLoggedIn();
  Future<void> saveHasSeenOnboarding(bool hasSeenOnboarding);
  bool hasSeenOnboarding();
  Future<void> clear();
}

class AppCacheImpl implements AppCache {
  final GetStorage _storage;

  AppCacheImpl(this._storage);

  static const _isLoggedInKey = 'is_logged_in';
  static const _hasSeenOnboardingKey = 'has_seen_onboarding';

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
  Future<void> clear() async {
    await _storage.erase();
  }
}
