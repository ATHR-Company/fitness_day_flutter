import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

/// Switches `image_picker` over to the platform photo pickers on Android.
///
/// `image_picker_android` still defaults to `useAndroidPhotoPicker = false`,
/// which sends gallery picks through `ACTION_GET_CONTENT` over `MediaStore`.
/// That path is filtered by the media read grant, so on Android 14+ a user who
/// answered "Select photos" only ever sees the subset granted the *first* time
/// — new selections never reach the app, and nothing re-prompts.
///
/// `ACTION_PICK_IMAGES` (with the Play services backport on older devices) runs
/// out of process and needs no permission at all: the full library is shown and
/// the app receives a fresh URI grant per pick. This is why the gallery branch
/// of [MediaPermissions] no longer asks for anything.
///
/// Must run after `WidgetsFlutterBinding.ensureInitialized()` so the platform
/// instance is registered. No-op on iOS, where `pickImage`/`pickMultiImage`
/// already use `PHPickerViewController`.
void configureMediaPickers() {
  final ImagePickerPlatform platform = ImagePickerPlatform.instance;
  if (platform is ImagePickerAndroid) {
    platform.useAndroidPhotoPicker = true;
  }
}
