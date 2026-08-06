import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/shared/conversations/presentation/utils/chat_time_format.dart';

/// Voice-note bubble — play/pause button, progress bar and elapsed duration.
class ChatAudioBubble extends StatefulWidget {
  /// An HTTP URL when [isNetwork] is true, otherwise a device file path.
  final String source;
  final bool isNetwork;

  const ChatAudioBubble({
    super.key,
    required this.source,
    this.isNetwork = false,
  });

  @override
  State<ChatAudioBubble> createState() => _ChatAudioBubbleState();
}

class _ChatAudioBubbleState extends State<ChatAudioBubble> {
  final AudioPlayer _player = AudioPlayer();
  final List<StreamSubscription<dynamic>> _subs = [];

  bool _isPlaying = false;
  bool _isCompleted = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  bool _sourceLoaded = false;
  bool _loadingSource = false;
  bool _disposed = false;

  Source get _source => widget.isNetwork
      ? UrlSource(widget.source)
      : DeviceFileSource(widget.source);

  @override
  void initState() {
    super.initState();

    // Without this the player releases its source the moment a clip finishes,
    // so the duration snapped back to 00:00 and playing again had to rebuild
    // the whole thing from scratch.
    _player.setReleaseMode(ReleaseMode.stop);

    _subs.add(_player.onDurationChanged.listen((d) {
      if (_disposed || d <= Duration.zero) return;
      setState(() => _duration = d);
    }));
    _subs.add(_player.onPositionChanged.listen((p) {
      if (_disposed || _isCompleted) return;
      setState(() => _position = p);
      // onPlayerComplete is unreliable on some Android builds, so the tail of
      // the clip counts as finished too. _handlePlaybackComplete is idempotent,
      // so whichever signal lands first wins and the other is a no-op.
      if (_isPlaying &&
          _duration > Duration.zero &&
          p.inMilliseconds >= _duration.inMilliseconds - 150) {
        _handlePlaybackComplete();
      }
    }));
    _subs.add(_player.onPlayerComplete.listen((_) => _handlePlaybackComplete()));

    // Load the clip's metadata up front so the bubble shows its length before
    // anyone presses play — the duration used to stay 00:00 until playback
    // started, and reopening the chat reset it to 00:00 again.
    //
    // Deferred by a frame so a list of voice notes doesn't prepare every
    // native player during the same build that is trying to paint them.
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureSource());
  }

  @override
  void dispose() {
    _disposed = true;
    for (final sub in _subs) {
      sub.cancel();
    }
    _player.dispose();
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    // Every callback here can land after the bubble scrolled out of the list.
    if (_disposed || !mounted) return;
    super.setState(fn);
  }

  Future<void> _handlePlaybackComplete() async {
    if (_disposed || _isCompleted) return;
    setState(() {
      _isCompleted = true;
      _isPlaying = false;
      _position = Duration.zero;
    });

    try {
      // pause() before seek(), and in that order.
      //
      // The onPositionChanged branch calls this 150ms *before* the clip
      // actually ends, so the player is still running at this point. Seeking a
      // running player back to zero doesn't stop it — it restarts it, which is
      // why every voice note played through exactly twice: once for real, then
      // once more from the rewind. Pausing first makes the rewind a rewind.
      await _player.pause();
      if (_disposed) return;
      await _player.seek(Duration.zero);
    } catch (e) {
      debugPrint('[ChatAudioBubble] reset after completion failed: $e');
    }
  }

  Future<void> _ensureSource() async {
    if (_sourceLoaded || _loadingSource || _disposed) return;
    _loadingSource = true;
    try {
      await _player.setSource(_source);
      if (_disposed) return;
      _sourceLoaded = true;

      // onDurationChanged usually fires on prepare, but it can be missed when
      // the platform reports the duration before this listener is attached.
      if (_duration <= Duration.zero) {
        final d = await _player.getDuration();
        if (!_disposed && d != null && d > Duration.zero) {
          setState(() => _duration = d);
        }
      }
    } catch (e) {
      debugPrint('[ChatAudioBubble] ⚠️ could not load ${widget.source}: $e');
    } finally {
      _loadingSource = false;
    }
  }

  Future<void> _toggle() async {
    if (_isPlaying) {
      await _player.pause();
      setState(() => _isPlaying = false);
      return;
    }

    await _ensureSource();
    if (_disposed || !_sourceLoaded) return;

    try {
      // Restart from the top when the previous run finished.
      if (_isCompleted || _position >= _duration && _duration > Duration.zero) {
        await _player.seek(Duration.zero);
        if (_disposed) return;
      }
      setState(() => _isCompleted = false);

      // resume(), not play(source): the source is already prepared by
      // _ensureSource, and handing play() a second Source made the player
      // prepare the same clip twice — which is why a voice note played back
      // doubled.
      await _player.resume();
      setState(() => _isPlaying = true);
    } catch (e) {
      debugPrint('[ChatAudioBubble] ⚠️ playback failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final double progress = _duration.inMilliseconds > 0
        ? (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;
    final Duration shown =
        _isPlaying || _position > Duration.zero ? _position : _duration;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _toggle,
            child: Icon(
              _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
              color: AppColors.primary,
              size: 34.sp,
            ),
          ),
          SizedBox(width: 8.w),
          SizedBox(
            width: 110.w,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4.h,
                    backgroundColor: AppColors.divider,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.mic,
                        size: 12.sp, color: AppColors.textSecondary),
                    SizedBox(width: 4.w),
                    Text(
                      formatChatDuration(shown),
                      style: TextStyleManager.style10Medium
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
