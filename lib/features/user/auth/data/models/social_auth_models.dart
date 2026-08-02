import 'package:equatable/equatable.dart';

class SocialAuthRequest extends Equatable {
  final String idToken;
  final String provider; // "APPLE", "GOOGLE"
  /// Null when the device cannot register for push — see [FcmHelper.getToken].
  final String? fcmToken;
  final String deviceType; // "ios", "android"

  const SocialAuthRequest({
    required this.idToken,
    required this.provider,
    this.fcmToken,
    required this.deviceType,
  });

  Map<String, dynamic> toJson() {
    return {
      'idToken': idToken,
      'provider': provider,
      'deviceType': deviceType,
      if (fcmToken != null) 'fcmToken': fcmToken,
    };
  }

  @override
  List<Object?> get props => [idToken, provider, fcmToken, deviceType];
}
