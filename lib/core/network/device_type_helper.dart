import 'dart:io';

/// Single source of truth for the `deviceType` string sent to the backend
/// on login/signup requests.
class DeviceTypeHelper {
  const DeviceTypeHelper._();

  static String get current => Platform.isIOS ? 'ios' : 'android';
}
