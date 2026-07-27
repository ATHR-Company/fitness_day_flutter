import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

/// Simple in-app browser used as the fallback when a file can't be opened by
/// any installed app.
///
/// Android's WebView can't render a PDF on its own, so [forDocument] wraps the
/// URL in Google's document viewer. iOS/WKWebView renders PDFs natively and
/// loads the URL directly.
class InAppWebViewPage extends StatefulWidget {
  final String url;
  final String? title;

  const InAppWebViewPage({super.key, required this.url, this.title});

  /// Opens [url] in the in-app browser, using the document viewer on Android.
  static Future<void> openDocument(
    BuildContext context, {
    required String url,
    String? title,
  }) {
    final bool useViewer = Theme.of(context).platform == TargetPlatform.android;
    final String target = useViewer
        ? 'https://docs.google.com/gview?embedded=true&url=${Uri.encodeComponent(url)}'
        : url;

    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => InAppWebViewPage(url: target, title: title),
      ),
    );
  }

  @override
  State<InAppWebViewPage> createState() => _InAppWebViewPageState();
}

class _InAppWebViewPageState extends State<InAppWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (_) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _hasError = true;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundTint,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.black),
        title: Text(
          widget.title ?? 'conversations.attach_document'.tr(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyleManager.style14Bold.copyWith(color: AppColors.black),
        ),
      ),
      body: Stack(
        children: [
          if (!_hasError) WebViewWidget(controller: _controller),
          if (_hasError)
            Center(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Text(
                  'conversations.cant_open_file'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyleManager.style11Medium
                      .copyWith(color: AppColors.textSecondary),
                ),
              ),
            ),
          if (_isLoading && !_hasError)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
        ],
      ),
    );
  }
}
