import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_day/core/widgets/app_image.dart';

/// Data model representing an image in the gallery.
class FullScreenImageItem {
  final String? imageUrl;
  final File? imageFile;
  final String heroTag;

  const FullScreenImageItem({
    this.imageUrl,
    this.imageFile,
    required this.heroTag,
  });
}

/// Displays an image (URL or local [File]) in a full-screen viewer with:
/// - Hero transition support via [heroTag]
/// - Pinch-to-zoom (up to 4×) with double-tap toggle
/// - Drag-down/up gesture to dismiss
/// - Animated arrow hint on first open
/// - Horizontal swipe to browse other images (if [items] is provided)
///
/// Use [FullScreenImageView.show] instead of pushing directly so the route
/// has a transparent barrier and a fade transition.
class FullScreenImageView extends StatefulWidget {
  final String? imageUrl;
  final File? imageFile;
  final String heroTag;
  final String? userName;
  final List<FullScreenImageItem>? items;
  final int initialIndex;

  const FullScreenImageView({
    super.key,
    this.imageUrl,
    this.imageFile,
    required this.heroTag,
    this.userName,
    this.items,
    this.initialIndex = 0,
  });

  /// Push a transparent, fading route that shows this widget.
  static Future<void> show(
    BuildContext context, {
    String? imageUrl,
    File? imageFile,
    required String heroTag,
    String? userName,
    List<FullScreenImageItem>? items,
    int initialIndex = 0,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.transparent,
        pageBuilder: (_, _, _) => FullScreenImageView(
          imageUrl: imageUrl,
          imageFile: imageFile,
          heroTag: heroTag,
          userName: userName,
          items: items,
          initialIndex: initialIndex,
        ),
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  State<FullScreenImageView> createState() => _FullScreenImageViewState();
}

class _FullScreenImageViewState extends State<FullScreenImageView>
    with TickerProviderStateMixin {
  late List<FullScreenImageItem> _items;
  late int _currentIndex;
  late PageController _pageController;

  late AnimationController _snapBackController;
  double _snapStartY = 0.0;
  double _dragY = 0.0;

  late AnimationController _arrowHintController;
  late Animation<double> _arrowHintAnimation;
  bool _isCurrentPageZoomed = false;

  @override
  void initState() {
    super.initState();

    // Prepare list of items
    if (widget.items != null && widget.items!.isNotEmpty) {
      _items = widget.items!;
      _currentIndex = widget.initialIndex;
    } else {
      _items = [
        FullScreenImageItem(
          imageUrl: widget.imageUrl,
          imageFile: widget.imageFile,
          heroTag: widget.heroTag,
        ),
      ];
      _currentIndex = 0;
    }

    _pageController = PageController(initialPage: _currentIndex);

    _snapBackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(() {
        setState(() {
          _dragY = _snapStartY * (1 - _snapBackController.value);
        });
      });

    _arrowHintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _arrowHintAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -14.0), weight: 25),
      TweenSequenceItem(tween: Tween(begin: -14.0, end: 0.0), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 25),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 0.0), weight: 25),
    ]).animate(
      CurvedAnimation(
        parent: _arrowHintController,
        curve: Curves.easeInOut,
      ),
    );

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _arrowHintController.forward();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _snapBackController.dispose();
    _arrowHintController.dispose();
    super.dispose();
  }

  void _handleDragStart() {
    if (_isCurrentPageZoomed) return;
    _snapBackController.stop();
  }

  void _handleDragMove(double dy) {
    if (_isCurrentPageZoomed) return;
    _snapBackController.stop();
    setState(() => _dragY += dy);
  }

  void _handleDragEnd() {
    if (_isCurrentPageZoomed) return;
    const threshold = 120.0;
    if (_dragY.abs() > threshold) {
      Navigator.pop(context);
    } else {
      _snapStartY = _dragY;
      _snapBackController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_dragY.abs() / 350).clamp(0.0, 1.0);
    final bgOpacity = (1.0 - progress).clamp(0.0, 1.0);
    final scale = (1.0 - progress * 0.6).clamp(0.4, 1.0);
    final screenW = MediaQuery.of(context).size.width;
    final borderRadius = progress * (screenW * scale / 2);

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(bgOpacity),
      body: Stack(
        children: [
          // ── Image PageView ──────────────────────────────────────────────────
          Listener(
            onPointerDown: (_) {
              if (!_isCurrentPageZoomed) _handleDragStart();
            },
            onPointerMove: (e) {
              if (!_isCurrentPageZoomed) _handleDragMove(e.delta.dy);
            },
            onPointerUp: (_) {
              if (!_isCurrentPageZoomed) _handleDragEnd();
            },
            child: Transform.translate(
              offset: Offset(0, _dragY),
              child: Transform.scale(
                scale: scale,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(borderRadius),
                  child: Container(
                    color: Colors.black,
                    width: double.infinity,
                    height: double.infinity,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _items.length,
                      physics: _isCurrentPageZoomed
                          ? const NeverScrollableScrollPhysics()
                          : const BouncingScrollPhysics(),
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                          _isCurrentPageZoomed = false;
                        });
                      },
                      itemBuilder: (context, index) {
                        return FullScreenImagePage(
                          item: _items[index],
                          onZoomChanged: (zoomed) {
                            if (_isCurrentPageZoomed != zoomed) {
                              setState(() {
                                _isCurrentPageZoomed = zoomed;
                              });
                            }
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),

          // // ── Page Indicator (if multiple items) ────────────────────────────
          // if (_items.length > 1)
          //   Positioned(
          //     top: MediaQuery.of(context).padding.top + 16.h,
          //     left: 0,
          //     right: 0,
          //     child: IgnorePointer(
          //       child: Center(
          //         child: Container(
          //           padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
          //           decoration: BoxDecoration(
          //             color: Colors.black.withOpacity(0.5),
          //             borderRadius: BorderRadius.circular(20.r),
          //           ),
          //           child: Text(
          //             '${_currentIndex + 1} / ${_items.length}',
          //             style: TextStyle(
          //               color: Colors.white,
          //               fontSize: 14.sp,
          //               fontWeight: FontWeight.bold,
          //             ),
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),

          // ── Dismiss arrow with hint animation ─────────────────────────────
          Positioned(
            bottom: 10.h,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: (1.0 - progress * 2).clamp(0.0, 1.0),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                onVerticalDragStart: (_) => _handleDragStart(),
                onVerticalDragUpdate: (d) => _handleDragMove(d.delta.dy),
                onVerticalDragEnd: (_) => _handleDragEnd(),
                child: AnimatedBuilder(
                  animation: _arrowHintAnimation,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(0, _arrowHintAnimation.value),
                    child: child,
                  ),
                  child: Container(
                    height: 80,
                    alignment: Alignment.center,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_up_rounded,
                        color: Colors.white,
                        size: 40.w,
                      ),
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

/// A stateful widget representing a single image page in the gallery.
/// Handles zooming (InteractiveViewer), double-tap zoom, and clamp scale animations.
class FullScreenImagePage extends StatefulWidget {
  final FullScreenImageItem item;
  final ValueChanged<bool> onZoomChanged;
  final VoidCallback? onTap;

  const FullScreenImagePage({
    super.key,
    required this.item,
    required this.onZoomChanged,
    this.onTap,
  });

  @override
  State<FullScreenImagePage> createState() => _FullScreenImagePageState();
}

class _FullScreenImagePageState extends State<FullScreenImagePage>
    with SingleTickerProviderStateMixin {
  final TransformationController _transformationController =
      TransformationController();

  late AnimationController _doubleTapController;
  Animation<Matrix4>? _doubleTapAnimation;

  @override
  void initState() {
    super.initState();
    _doubleTapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _transformationController.addListener(_clampScale);
  }

  void _clampScale() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    if (scale < 1.0) {
      _transformationController.value = Matrix4.identity();
    }
    widget.onZoomChanged(scale > 1.05);
  }

  @override
  void dispose() {
    _transformationController.removeListener(_clampScale);
    _transformationController.dispose();
    _doubleTapController.dispose();
    super.dispose();
  }

  bool get _isZoomed =>
      _transformationController.value.getMaxScaleOnAxis() > 1.05;

  void _onDoubleTapDown(TapDownDetails details) {
    _doubleTapController.stop();
    final begin = _transformationController.value;
    final Matrix4 end;

    if (_isZoomed) {
      end = Matrix4.identity();
    } else {
      final pos = details.localPosition;
      end = Matrix4.identity()
        ..translate(-pos.dx * 1.5, -pos.dy * 1.5)
        ..scale(2.5);
    }

    _doubleTapAnimation = Matrix4Tween(begin: begin, end: end).animate(
      CurvedAnimation(
        parent: _doubleTapController,
        curve: Curves.easeInOut,
      ),
    )..addListener(() {
        _transformationController.value = _doubleTapAnimation!.value;
      });

    _doubleTapController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: _onDoubleTapDown,
      onDoubleTap: () {},
      onTap: widget.onTap,
      child: Hero(
        tag: widget.item.heroTag,
        child: InteractiveViewer(
          transformationController: _transformationController,
          minScale: 1.0,
          maxScale: 4.0,
          panEnabled: true,
          scaleEnabled: true,
          constrained: true,
          boundaryMargin: EdgeInsets.zero,
          child: SizedBox.expand(
            child: widget.item.imageFile != null
                ? Image.file(
                    widget.item.imageFile!,
                    fit: BoxFit.contain,
                  )
                : AppImage(
                    widget.item.imageUrl,
                    fit: BoxFit.contain,
                  ),
          ),
        ),
      ),
    );
  }
}
