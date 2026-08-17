import 'dart:ui';

import 'package:fitness_day/core/constant/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:omni_image/omni_image.dart';

// ══════════════════════════════════════════════════════════════════════════════
// ⭐ AppImage — unified widget for every image type
//
// Supported paths:
//   • "assets/svg/icon.svg"     → SvgPicture.asset
//   • "https://…/icon.svg"      → SvgPicture.network
//   • "https://…/photo.png"     → OmniImage (cached network raster)
//   • "assets/images/img.png"   → Image.asset
//   • "assets/lottie/anim.json" → Lottie.asset
//   • "assets/images/anim.gif"  → Image.asset (gif)
//   • null / ""                 → placeholder / SizedBox
// ══════════════════════════════════════════════════════════════════════════════
class AppImage extends StatelessWidget {
  final String? path;
  final double? height;
  final double? width;
  final BoxFit fit;
  final Color? color;
  final Gradient? gradientColorSvg;
  final String? placeholderImage;

  /// When true and path is null/empty, shows [SvgIcons.emptyProfile] fallback.
  final bool isAvatar;

  /// Clips the image to a rounded rectangle with this radius.
  final double? radius;

  /// Applies a [BackdropFilter] blur on top of the image (network only).
  final double? blur;

  /// Mirrors the image horizontally when the layout direction is LTR.
  final bool flipOnLtr;

  /// Alignment of the image within its bounds.
  final Alignment alignment;

  const AppImage(
    this.path, {
    super.key,
    this.height,
    this.width,
    this.fit = BoxFit.contain,
    this.color,
    this.gradientColorSvg,
    this.placeholderImage,
    this.isAvatar = false,
    this.radius,
    this.blur,
    this.flipOnLtr = false,
    this.alignment = Alignment.center,
  });

  // ── Helpers ──────────────────────────────────────────────────────────────

  Widget _flipIfLtr(Widget child, BuildContext context) {
    if (!flipOnLtr) return child;
    if (Directionality.of(context) != TextDirection.ltr) return child;
    return Transform.scale(scaleX: -1, child: child);
  }

  Widget _clip(Widget child) {
    if (radius != null && radius! > 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius!),
        child: child,
      );
    }
    return child;
  }

  Widget _gradient(Widget child) {
    if (gradientColorSvg == null) return child;
    return ShaderMask(
      shaderCallback: (bounds) => gradientColorSvg!.createShader(bounds),
      blendMode: BlendMode.srcIn,
      child: child,
    );
  }

  Widget _align(Widget child) {
    if (alignment == Alignment.center) return child;
    return Align(alignment: alignment, child: child);
  }

  ColorFilter? get _svgColorFilter {
    if (gradientColorSvg != null || color == null) return null;
    return ColorFilter.mode(color!, BlendMode.srcIn);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final p = path;

    if (p == null || p.isEmpty) return _buildFallback();

    final ext = p.split('.').last.toLowerCase();

    if (ext == 'svg') return _buildSvg(p, context);

    if (ext == 'json') {
      return _clip(
        Lottie.asset(
          p,
          fit: fit,
          height: height,
          width: width,
        ),
      );
    }

    if (p.startsWith('http')) return _buildNetwork(p, context);

    // Local asset — raster (png / jpg / gif / webp …)
    return _buildAsset(p, context);
  }

  // ── SVG ───────────────────────────────────────────────────────────────────

  Widget _buildSvg(String p, BuildContext context) {
    final svgWidget = p.startsWith('http')
        ? SvgPicture.network(
            p,
            fit: fit,
            height: height,
            width: width,
            alignment: alignment,
            colorFilter: _svgColorFilter,
            placeholderBuilder: (_) => _loadingBox(),
          )
        : SvgPicture.asset(
            p,
            fit: fit,
            height: height,
            width: width,
            alignment: alignment,
            colorFilter: _svgColorFilter,
            placeholderBuilder: (_) => _loadingBox(),
          );

    return _flipIfLtr(_clip(_gradient(_align(svgWidget))), context);
  }

  // ── Decode size ───────────────────────────────────────────────────────────
  //
  // A bitmap costs `width × height × 4` bytes in memory *whatever size it is
  // drawn at* — a 1200×1200 product photo is 5.5 MB even inside a 48 px
  // thumbnail. These decode it near the size it actually renders at.

  /// Ceiling for images whose display size isn't known here.
  ///
  /// Wide enough for a full-bleed banner on a 3x phone, and it costs nothing
  /// when the source is smaller: a target above the original is ignored rather
  /// than upscaled.
  static const int _maxDecodeWidth = 1080;

  int? _decodeWidth(BuildContext context) => _decodePixels(context, width);

  /// Only used when there is a height to go by and no width — passing both
  /// resizes the bitmap to those exact dimensions, which squashes it.
  ///
  /// The `height != null` half matters as much as the `width == null` half.
  /// With both unset — a full-bleed image that simply fills its parent, as in
  /// the full-screen viewer — [_decodePixels] answers with its [_maxDecodeWidth]
  /// fallback for *either* axis, so returning it here handed the decoder
  /// 1080×1080 and every photo came out stretched to a square. A cap on one
  /// axis alone scales proportionally, which is what was always intended.
  int? _decodeHeight(BuildContext context) =>
      (width == null && height != null) ? _decodePixels(context, height) : null;

  /// Logical pixels → device pixels, capped.
  ///
  /// Guards non-finite sizes on purpose: `AppImage` is often given
  /// `double.infinity` (it fills its parent), and `infinity.round()` throws.
  int? _decodePixels(BuildContext context, double? logical) {
    if (logical == null || !logical.isFinite || logical <= 0) {
      return _maxDecodeWidth;
    }
    final double devicePixels =
        logical * MediaQuery.devicePixelRatioOf(context);
    if (!devicePixels.isFinite || devicePixels <= 0) return _maxDecodeWidth;
    return devicePixels.round().clamp(1, _maxDecodeWidth);
  }

  // ── Network raster (png / jpg / gif / webp …) ────────────────────────────
  //
  // OmniImage handles both SVG and raster URLs, caches via NetworkImage /
  // SvgPicture.network internally, and is already in pubspec.yaml.

  Widget _buildNetwork(String p, BuildContext context) {
    Widget image = OmniImage(
      image: p,
      fit: fit,
      height: height,
      width: width,
      color: blur != null ? null : color,
      memCacheWidth: _decodeWidth(context),
      memCacheHeight: _decodeHeight(context),
    );

    if (blur != null) {
      image = SizedBox(
        height: height,
        width: width,
        child: Stack(
          fit: StackFit.expand,
          children: [
            OmniImage(
              image: p,
              fit: fit,
              memCacheWidth: _decodeWidth(context),
              memCacheHeight: _decodeHeight(context),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blur!, sigmaY: blur!),
              child: Container(color: Colors.transparent),
            ),
          ],
        ),
      );
    }

    return RepaintBoundary(
      child: _flipIfLtr(_clip(_gradient(_align(image))), context),
    );
  }

  // ── Local asset raster ────────────────────────────────────────────────────

  Widget _buildAsset(String p, BuildContext context) {
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final safeW = width;
    final safeH = height;

    final image = Image.asset(
      p,
      height: height,
      width: width,
      fit: fit,
      color: color,
      alignment: alignment,
      cacheWidth: (safeW != null && safeW.isFinite && safeW > 0)
          ? (safeW * pixelRatio).toInt()
          : null,
      cacheHeight: (safeH != null && safeH.isFinite && safeH > 0)
          ? (safeH * pixelRatio).toInt()
          : null,
      errorBuilder: (_, _, _) => _buildErrorWidget(),
    );

    return _flipIfLtr(_clip(_gradient(_align(image))), context);
  }

  // ── Fallbacks ─────────────────────────────────────────────────────────────

  Widget _buildFallback() {
    if (placeholderImage != null) {
      return _clip(
        Image.asset(
          placeholderImage!,
          height: height,
          width: width,
          fit: fit,
        ),
      );
    }
    if (isAvatar) {
      return _clip(
        SvgPicture.asset(
          SvgIcons.emptyProfile,
          height: height,
          width: width,
          fit: fit,
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildErrorWidget() {
    if (placeholderImage != null) {
      return Image.asset(
        placeholderImage!,
        height: height,
        width: width,
        fit: fit,
      );
    }
    if (isAvatar) {
      return SvgPicture.asset(
        SvgIcons.emptyProfile,
        height: height,
        width: width,
        fit: fit,
      );
    }
    return Container(
      height: height,
      width: width,
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: Colors.grey[350],
          size: 32.sp,
        ),
      ),
    );
  }

  Widget _loadingBox() => Container(
        height: height,
        width: width,
        color: Colors.grey[200],
      );
}
