import 'dart:io';

import 'package:flutter/foundation.dart';
// XFile comes from `cross_file`, which flutter_image_compress re-exports —
// the same type image_picker hands back.
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

/// Compresses picked media before it is uploaded.
///
/// `image_picker`'s `imageQuality` only applies to images it decodes itself and
/// is skipped entirely on some Android OEM galleries, so pictures were being
/// uploaded at full size (several MB each). This runs a real re-encode pass on
/// the picked file and writes the result to the temp directory.
///
/// Videos, audio and documents are returned untouched — video re-encoding needs
/// a native transcoder package which isn't part of the project yet.
class MediaCompressor {
  const MediaCompressor._();

  static const Set<String> _imageExtensions = {
    'jpg',
    'jpeg',
    'png',
    'heic',
    'heif',
    'webp',
  };

  /// Files already smaller than this are uploaded as-is — re-encoding them
  /// costs time and can even make them bigger.
  static const int _skipBelowBytes = 150 * 1024;

  /// Shorter side of the output image. Long side follows the aspect ratio.
  static const int _minSide = 1080;

  static const int _quality = 65;

  /// Compresses every image in [files], keeping non-image files unchanged.
  /// Order is preserved so the caller can rely on the indexes.
  static Future<List<XFile>> compressAll(List<XFile> files) async {
    final List<XFile> out = [];
    for (final f in files) {
      out.add(await compress(f));
    }
    return out;
  }

  /// Compresses a single file. Always returns something usable: on any
  /// failure (unsupported format, decode error, no size gain) the original
  /// [file] is returned so sending never breaks because of compression.
  static Future<XFile> compress(XFile file) async {
    final String ext = _extensionOf(file.path);
    if (!_imageExtensions.contains(ext)) return file;

    try {
      final File original = File(file.path);
      if (!original.existsSync()) return file;

      final int originalBytes = await original.length();
      if (originalBytes <= _skipBelowBytes) return file;

      final Directory dir = await getTemporaryDirectory();
      final String target =
          '${dir.path}/cmp_${DateTime.now().microsecondsSinceEpoch}.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        original.absolute.path,
        target,
        quality: _quality,
        minWidth: _minSide,
        minHeight: _minSide,
        format: CompressFormat.jpeg,
        keepExif: false,
      );
      if (result == null) return file;

      final int compressedBytes = await File(result.path).length();
      if (compressedBytes >= originalBytes) return file;

      debugPrint(
        '[MediaCompressor] ${_readable(originalBytes)} → ${_readable(compressedBytes)} '
        '(${(100 - (compressedBytes / originalBytes * 100)).round()}% smaller)',
      );

      return XFile(result.path, name: _jpegNameFor(file));
    } catch (e) {
      debugPrint('[MediaCompressor] ⚠️ compression skipped: $e');
      return file;
    }
  }

  static String _extensionOf(String path) {
    final String name = path.split(RegExp(r'[/\\]')).last;
    final int dot = name.lastIndexOf('.');
    return dot == -1 ? '' : name.substring(dot + 1).toLowerCase();
  }

  /// Keeps the original file name for the upload but swaps the extension,
  /// since the output is always JPEG.
  static String _jpegNameFor(XFile file) {
    final String name = file.name;
    final int dot = name.lastIndexOf('.');
    final String base = dot == -1 ? name : name.substring(0, dot);
    return '$base.jpg';
  }

  static String _readable(int bytes) =>
      '${(bytes / 1024).toStringAsFixed(0)} KB';
}
