import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/widgets/in_app_web_view_page.dart';

/// Opens a chat attachment (PDF, doc, sheet, …).
///
/// Order of attempts:
///   1. Download the file to the cache directory (skipped when it is already
///      a local file, e.g. an attachment that is still uploading).
///   2. Hand it to an installed app via `OpenFilex` — the native PDF/Office
///      viewer, so the user gets the full reader experience.
///   3. If no app on the device can handle it, fall back to the in-app
///      WebView ([InAppWebViewPage]).
class AttachmentOpener {
  const AttachmentOpener._();

  static final Dio _dio = Dio();

  static Future<void> open(
    BuildContext context, {
    required String url,
    String? fileName,
  }) async {
    final String name = fileName ?? _nameFromUrl(url);

    // Local file (optimistic bubble) — nothing to download.
    if (!url.startsWith('http')) {
      final result = await OpenFilex.open(url);
      if (result.type != ResultType.done && context.mounted) {
        _showCantOpen(context);
      }
      return;
    }

    _showLoading(context);
    String? localPath;
    try {
      localPath = await _download(url, name);
    } catch (e) {
      debugPrint('[AttachmentOpener] ⚠️ download failed: $e');
    }
    if (!context.mounted) return;
    _hideLoading(context);

    if (localPath != null) {
      final result = await OpenFilex.open(localPath);
      debugPrint('[AttachmentOpener] OpenFilex → ${result.type} (${result.message})');
      if (result.type == ResultType.done) return;
    }

    // No app could open it (or the download failed) → in-app WebView.
    if (!context.mounted) return;
    await InAppWebViewPage.openDocument(context, url: url, title: name);
  }

  // ── Internals ──────────────────────────────────────────────────────────────

  /// Downloads [url] into the cache dir and returns the local path.
  /// A file already fetched before is reused instead of downloaded again.
  static Future<String> _download(String url, String name) async {
    final Directory dir = await getTemporaryDirectory();
    final String path = '${dir.path}/att_${url.hashCode}_$name';

    final File file = File(path);
    if (file.existsSync() && await file.length() > 0) {
      debugPrint('[AttachmentOpener] ♻️ using cached file $path');
      return path;
    }

    debugPrint('[AttachmentOpener] ⬇️ downloading $url');
    await _dio.download(url, path);
    return path;
  }

  static String _nameFromUrl(String url) {
    final String last = Uri.tryParse(url)?.pathSegments.last ?? url.split('/').last;
    return last.isEmpty ? 'file' : last;
  }

  static void _showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black38,
      builder: (_) => Center(
        child: Container(
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: const CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
    );
  }

  static void _hideLoading(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  static void _showCantOpen(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('conversations.cant_open_file'.tr())),
    );
  }
}
