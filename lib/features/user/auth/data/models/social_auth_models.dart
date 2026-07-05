import 'package:equatable/equatable.dart';

class SocialAuthRequest extends Equatable {
  final String idToken;
  final String provider; // "APPLE", "GOOGLE"
  final String fcmToken;
  final String deviceType; // "ios", "android"

  const SocialAuthRequest({
    required this.idToken,
    required this.provider,
    required this.fcmToken,
    required this.deviceType,
  });

  Map<String, dynamic> toJson() {
    return {
      'idToken': idToken,
      'provider': provider,
      'fcmToken': fcmToken,
      'deviceType': deviceType,
    };
  }

  @override
  List<Object?> get props => [idToken, provider, fcmToken, deviceType];
}
