import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

/// Owns a voice-note recording session for the chat composer.
///
/// The permission check, the temp file and the one-second tick all live here,
/// so the page only has to react to [isRecording] and [elapsed].
class ChatVoiceRecorder extends ChangeNotifier {
  final AudioRecorder _recorder = AudioRecorder();

  Timer? _timer;
  String? _path;
  bool _isRecording = false;
  bool _disposed = false;
  Duration _elapsed = Duration.zero;

  bool get isRecording => _isRecording;
  Duration get elapsed => _elapsed;

  /// Starts a new recording. Returns false when the microphone permission was
  /// denied or the recorder failed to start — the caller shows the message.
  Future<bool> start() async {
    try {
      if (!await _recorder.hasPermission()) return false;

      final dir = await getTemporaryDirectory();
      _path = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(const RecordConfig(), path: _path!);

      _isRecording = true;
      _elapsed = Duration.zero;
      _notify();

      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        _elapsed += const Duration(seconds: 1);
        _notify();
      });
      return true;
    } catch (_) {
      await _reset(deleteFile: true);
      return false;
    }
  }

  /// Stops the recording and returns the captured file, or null when nothing
  /// usable was recorded.
  Future<File?> stop() async {
    final String? path = await _stopRecorder();
    await _reset();
    if (path == null) return null;
    final file = File(path);
    return file.existsSync() ? file : null;
  }

  /// Stops the recording and throws the file away.
  Future<void> cancel() => _reset(deleteFile: true);

  Future<String?> _stopRecorder() async {
    _timer?.cancel();
    try {
      return await _recorder.stop() ?? _path;
    } catch (_) {
      return _path;
    }
  }

  Future<void> _reset({bool deleteFile = false}) async {
    if (deleteFile) {
      final String? path = await _stopRecorder();
      if (path != null) {
        try {
          final file = File(path);
          if (file.existsSync()) await file.delete();
        } catch (_) {}
      }
    }

    _timer?.cancel();
    _timer = null;
    _path = null;
    _isRecording = false;
    _elapsed = Duration.zero;
    _notify();
  }

  /// A recording that finishes after the page is gone must not notify.
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _recorder.dispose();
    super.dispose();
  }
}
