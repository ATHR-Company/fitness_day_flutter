import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/theme/app_colors.dart';

/// Full-screen image viewer with pinch-to-zoom and a close button.
///
/// Accepts either a [networkUrl] or a local [file] — exactly one must be
/// provided. Shows a black background with system UI hidden for an immersive
/// experience.
///
/// Usage:
/// ```dart
/// // From a network URL
/// ImageFullScreenViewer.show(context, networkUrl: 'https://...');
///
/// // From a local file
/// ImageFullScreenViewer.show(context, file: File('/path/to/file.jpg'));
/// ```
class ImageFullScreenViewer extends StatefulWidget {
  final String? networkUrl;
  final File? file;

  const ImageFullScreenViewer._({this.networkUrl, this.file})
      : assert(
          (networkUrl != null) != (file != null),
          'Provide exactly one of networkUrl or file',
        );

  /// Pushes a full-screen viewer onto the navigator stack.
  static Future<void> show(
    BuildContext context, {
    String? networkUrl,
    File? file,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        barrierDismissible: true,
        transitionDuration: const Duration(milliseconds: 220),
        reverseTransitionDuration: const Duration(milliseconds: 180),
        pageBuilder: (_, _, _) => ImageFullScreenViewer._(
          networkUrl: networkUrl,
          file: file,
        ),
        transitionsBuilder: (_, animation, _, child) => FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
    );
  }

  @override
  State<ImageFullScreenViewer> createState() => _ImageFullScreenViewerState();
}

class _ImageFullScreenViewerState extends State<ImageFullScreenViewer> {
  final TransformationController _transformController =
      TransformationController();

  @override
  void initState() {
    super.initState();
    // Hide status + navigation bars for full immersion
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _transformController.dispose();
    // Restore system UI when leaving the viewer
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _resetZoom() {
    _transformController.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    final ImageProvider imageProvider = widget.file != null
        ? FileImage(widget.file!) as ImageProvider
        : NetworkImage(widget.networkUrl!);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Zoomable image ───────────────────────────────────────────
          GestureDetector(
            // Double-tap resets zoom
            onDoubleTap: _resetZoom,
            child: InteractiveViewer(
              transformationController: _transformController,
              minScale: 0.8,
              maxScale: 5.0,
              child: Center(
                child: Image(
                  image: imageProvider,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                  loadingBuilder: (_, child, chunk) {
                    if (chunk == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        value: chunk.expectedTotalBytes != null
                            ? chunk.cumulativeBytesLoaded /
                                chunk.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (_, _, _) => Center(
                    child: Icon(
                      Icons.broken_image_rounded,
                      color: AppColors.textSecondary,
                      size: 64.sp,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Close button (top-leading corner) ────────────────────────
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(12.r),
              child: Align(
                alignment: AlignmentDirectional.topStart,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 40.r,
                    height: 40.r,
                    decoration: BoxDecoration(
                      color: AppColors.black.withValues(alpha: 0.55),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: AppColors.white,
                      size: 22.sp,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
