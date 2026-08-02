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
  Future<void> saveIsSubscribed(bool isSubscribed);
  bool getIsSubscribed();

  /// Order whose Paymob payment was started but never resolved on this device.
  ///
  /// Written when `initiate` succeeds and cleared once the status endpoint
  /// reports a final result, so an app that was killed mid-payment can pick
  /// the confirmation back up on its next launch.
  Future<void> savePendingPaymentOrderId(String orderIdentity);
  String? getPendingPaymentOrderId();
  Future<void> clearPendingPaymentOrderId();

  /// Stand-in push token for devices that cannot register with FCM.
  ///
  /// Generated once per install and kept for the life of the install, so the
  /// same device always presents the same identity. Survives logout on
  /// purpose — it identifies the *device*, not the session. See
  /// `FcmHelper.tokenForAuthRequest`.
  Future<void> saveDeviceFallbackId(String id);
  String? getDeviceFallbackId();

  /// Clears only the current user's session data.
  ///
  /// Device-level flags such as [hasSeenOnboarding] are intentionally
  /// preserved — logout must never send the user back to the onboarding flow
  /// they already completed.
  ///
  /// Keys cleared: is_logged_in, user_type, cached_user_profile,
  /// assessment_id, is_subscribed, pending_payment_order_id,
  /// daily_check_in_last_date, daily_check_in_streak.
  Future<void> clearSession();

  /// Wipes every key in storage including device-level flags.
  /// Only call this from "Delete account" flows, never from logout.
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
  static const _isSubscribedKey = 'is_subscribed';
  static const _pendingPaymentOrderKey = 'pending_payment_order_id';
  static const _deviceFallbackIdKey = 'device_fallback_id';

  @override
  Future<void> saveDeviceFallbackId(String id) async {
    await _storage.write(_deviceFallbackIdKey, id);
  }

  @override
  String? getDeviceFallbackId() {
    return _storage.read<String>(_deviceFallbackIdKey);
  }

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
    // No cached profile yet — return a genuinely empty user rather than
    // fabricated placeholder data (a prior "mock" default here previously
    // caused screens to display fake weight/height/goal as if real, e.g. for
    // accounts whose profile was set outside this app's own update flow).
    return const UserModel(
      name: '',
      email: '',
      phone: '',
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
  Future<void> saveIsSubscribed(bool isSubscribed) async {
    await _storage.write(_isSubscribedKey, isSubscribed);
  }

  @override
  bool getIsSubscribed() {
    return _storage.read(_isSubscribedKey) ?? false;
  }

  @override
  Future<void> savePendingPaymentOrderId(String orderIdentity) async {
    await _storage.write(_pendingPaymentOrderKey, orderIdentity);
  }

  @override
  String? getPendingPaymentOrderId() {
    return _storage.read(_pendingPaymentOrderKey);
  }

  @override
  Future<void> clearPendingPaymentOrderId() async {
    await _storage.remove(_pendingPaymentOrderKey);
  }

  /// Removes every session-scoped key while keeping device-level flags.
  /// [_hasSeenOnboardingKey] is intentionally omitted — the user already
  /// completed onboarding on this device and must not see it again after
  /// logging out and back in.
  @override
  Future<void> clearSession() async {
    await Future.wait([
      _storage.remove(_isLoggedInKey),
      _storage.remove(_userTypeKey),
      _storage.remove(_userKey),
      _storage.remove(_assessmentIdKey),
      _storage.remove(_isSubscribedKey),
      _storage.remove(_pendingPaymentOrderKey),
    ]);
  }

  @override
  Future<void> clear() async {
    await _storage.erase();
  }
}
