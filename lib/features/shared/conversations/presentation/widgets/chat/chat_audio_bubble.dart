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

  bool _isPlaying = false;
  bool _isCompleted = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  /// The source is loaded on the first play instead of in [initState].
  /// Preloading every bubble spun up a native MediaPlayer (and an HTTP
  /// connection for remote clips) for each voice note the list scrolled past,
  /// which stuttered the scroll and threw "Bad state: No element" whenever the
  /// bubble was disposed mid-load.
  bool _sourceLoaded = false;

  void _handlePlaybackComplete() {
    if (!mounted) return;
    setState(() {
      _isCompleted = true;
      _isPlaying = false;
      _position = Duration.zero;
    });
    _player.seek(Duration.zero).catchError((e) {
      debugPrint('[ChatAudioBubble] seek failed: $e');
    });
  }

  @override
  void initState() {
    super.initState();
    _player.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
    _player.onPositionChanged.listen((p) {
      if (mounted && !_isCompleted) {
        setState(() => _position = p);
        if (_isPlaying &&
            _duration > Duration.zero &&
            p.inMilliseconds >= _duration.inMilliseconds - 150) {
          _handlePlaybackComplete();
        }
      }
    });
    _player.onPlayerComplete.listen((_) {
      _handlePlaybackComplete();
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _ensureSource() async {
    if (_sourceLoaded) return;
    try {
      if (widget.isNetwork) {
        await _player.setSourceUrl(widget.source);
      } else {
        await _player.setSourceDeviceFile(widget.source);
      }
      _sourceLoaded = true;
    } catch (e) {
      debugPrint('[ChatAudioBubble] ⚠️ could not load ${widget.source}: $e');
    }
  }

  Future<void> _toggle() async {
    if (_isPlaying) {
      await _player.pause();
      if (mounted) setState(() => _isPlaying = false);
      return;
    }

    await _ensureSource();
    if (!mounted) return;
    try {
      if (mounted) {
        setState(() {
          _isCompleted = false;
        });
      }
      // After onPlayerComplete, the player is in the "completed" state at
      // position 0.  Calling resume() on some platform implementations
      // silently no-ops in that state.  We always call play() instead, which
      // works whether the player is stopped, paused, or completed.
      await _player.play(
        widget.isNetwork
            ? UrlSource(widget.source)
            : DeviceFileSource(widget.source),
      );
      if (mounted) setState(() => _isPlaying = true);
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
