import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// Reclaims a camera result Android threw away together with the Activity.
///
/// The camera runs in its own app. While it is in the foreground the system is
/// free to kill this app's process to reclaim memory — and on cheaper devices it
/// routinely does. What the user sees is: frame the shot, tap the shutter, leave
/// the app for a moment, come back to the camera still open and the photo gone.
///
/// The photo is not actually gone. `pickImage` never returns, because the isolate
/// that was awaiting it no longer exists, but the platform side has already
/// written the file and remembers it. [take] is the hand-off: it asks the plugin
/// for whatever was stranded and gives it back to the screen that asked.
///
/// Android only — every other platform reports nothing lost.
///
/// The cache holds one result and reading it clears it, so exactly one caller can
/// claim a given shot. Call it from `initState` of the screen that owns the
/// picked file, not from a widget that is rebuilt or from app-wide startup.
class LostMediaRecovery {
  const LostMediaRecovery._();

  /// Returns the stranded files, or an empty list when nothing was lost.
  ///
  /// Pass [only] to ignore a result of the wrong kind — a profile avatar should
  /// not adopt a video the chat composer was recording. Note that the plugin's
  /// cache is cleared either way: it cannot be inspected without consuming it.
  static Future<List<XFile>> take({RetrieveType? only}) async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return const <XFile>[];
    }

    try {
      final LostDataResponse response = await ImagePicker().retrieveLostData();

      // `isEmpty` covers the ordinary case — nothing was interrupted. A response
      // carrying an exception means the platform side failed mid-capture; there
      // is no file to hand back, and the user simply retakes the shot.
      if (response.isEmpty || response.exception != null) {
        return const <XFile>[];
      }
      if (only != null && response.type != only) return const <XFile>[];

      final List<XFile>? files = response.files;
      if (files != null && files.isNotEmpty) return files;

      final XFile? file = response.file;
      return file == null ? const <XFile>[] : <XFile>[file];
    } catch (e) {
      // Recovery is a bonus path: a failure here must never take down the screen
      // that is merely opening.
      debugPrint('LostMediaRecovery.take error: $e');
      return const <XFile>[];
    }
  }
}
