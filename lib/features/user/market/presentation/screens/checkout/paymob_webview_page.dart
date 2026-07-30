import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:fitness_day/core/constant/api_endpoints.dart';
import 'package:fitness_day/core/theme/app_colors.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';

/// Why the payment WebView closed.
///
/// None of these is a verdict on its own — the backend is still asked what
/// happened. A buyer dismissing the page is never assumed to mean "cancelled":
/// they may have paid and then closed it.
enum PaymobWebViewResult {
  /// Paymob redirected to the return URL — the buyer is done here.
  returned,

  /// Paymob's page reported the transaction was declined.
  declined,

  /// The buyer backed out of the page themselves.
  dismissed,
}

/// Hosts Paymob's checkout page. Card details are entered here and never touch
/// the app — that is the whole point of using the hosted page.
///
/// This screen decides nothing. It closes as soon as the buyer is done and
/// leaves the verdict to `GET /payments/paymob/orders/:id/status`.
class PaymobWebViewPage extends StatefulWidget {
  final String webviewUrl;

  /// Shown next to the title so the buyer can see what they are paying.
  final double amount;
  final String currency;

  const PaymobWebViewPage({
    super.key,
    required this.webviewUrl,
    required this.amount,
    required this.currency,
  });

  /// Opens the checkout and resolves once it closes, for either reason.
  /// Never returns null — a system back gesture resolves to [dismissed].
  static Future<PaymobWebViewResult> open(
    BuildContext context, {
    required String webviewUrl,
    required double amount,
    required String currency,
  }) async {
    final result = await Navigator.of(context).push<PaymobWebViewResult>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => PaymobWebViewPage(
          webviewUrl: webviewUrl,
          amount: amount,
          currency: currency,
        ),
      ),
    );
    return result ?? PaymobWebViewResult.dismissed;
  }

  @override
  State<PaymobWebViewPage> createState() => _PaymobWebViewPageState();
}

class _PaymobWebViewPageState extends State<PaymobWebViewPage> {
  /// Channel the injected watcher reports the decline screen through.
  static const String _declineChannel = 'FitnessDayPaymobDecline';

  /// Long enough for the buyer to read "Payment declined" before the page
  /// closes — short enough that they never reach Paymob's own retry button,
  /// which would start a second transaction outside the app's flow.
  static const Duration _declineCloseDelay = Duration(milliseconds: 1200);

  late final WebViewController _controller;
  bool _isLoading = true;

  /// Guards against closing twice — `onNavigationRequest` and `onUrlChange`
  /// can both see the return URL.
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.white)
      ..addJavaScriptChannel(
        _declineChannel,
        onMessageReceived: (_) => _onDeclineDetected(),
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          // Intercepting *before* the request goes out matters: the return URL
          // responds with raw JSON, which the buyer must never see.
          onNavigationRequest: (request) {
            if (_isReturnUrl(request.url)) {
              _close(PaymobWebViewResult.returned);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          // Backstop for redirects that don't surface as navigation requests.
          onUrlChange: (change) {
            if (_isReturnUrl(change.url ?? '')) {
              _close(PaymobWebViewResult.returned);
            }
          },
          onPageStarted: (_) {
            if (mounted && !_isClosing) setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (mounted && !_isClosing) setState(() => _isLoading = false);
            _installDeclineWatcher();
          },
          // A network hiccup on the hosted page is not a payment verdict —
          // let the buyer close, and the status poll settles it.
          onWebResourceError: (_) {
            if (mounted && !_isClosing) setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.webviewUrl));
  }

  bool _isReturnUrl(String url) =>
      url.contains(ApiEndpoints.paymobReturnPath);

  /// Watches the hosted page for its decline screen.
  ///
  /// Paymob does **not** redirect to the return URL when a transaction is
  /// declined — it renders "Payment declined" in place and offers its own
  /// retry button. Letting the buyer use that button would run a second
  /// transaction the app never asked for and knows nothing about, so instead
  /// the page is watched and closed, and retrying goes back through the app.
  ///
  /// It is a single-page app, so this polls the rendered text rather than
  /// waiting on a navigation that never comes. The script guards itself
  /// against being installed twice (`onPageFinished` fires per document).
  void _installDeclineWatcher() {
    _controller.runJavaScript('''
(function () {
  if (window.__fdDeclineWatcher) return;
  window.__fdDeclineWatcher = true;

  // Phrases the decline screen renders, in both languages Paymob serves us.
  // Deliberately specific: a bare "failed" also appears in unrelated copy.
  var markers = [
    'payment declined',
    'transaction declined',
    'payment failed',
    'transaction failed',
    'authentication_failed',
    'فشلت عملية الدفع',
    'تم رفض',
    'مرفوضة',
    'فشل الدفع'
  ];

  function check() {
    var text = document.body ? (document.body.innerText || '') : '';
    var haystack = text.toLowerCase();
    for (var i = 0; i < markers.length; i++) {
      if (haystack.indexOf(markers[i]) !== -1) {
        clearInterval(window.__fdDeclineTimer);
        $_declineChannel.postMessage('declined');
        return;
      }
    }
  }

  window.__fdDeclineTimer = setInterval(check, 600);
  check();
})();
''');
  }

  Future<void> _onDeclineDetected() async {
    if (_isClosing || !mounted) return;
    await Future.delayed(_declineCloseDelay);
    _close(PaymobWebViewResult.declined);
  }

  void _close(PaymobWebViewResult result) {
    if (_isClosing || !mounted) return;
    _isClosing = true;
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Let the buyer leave freely; the caller polls either way.
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) _isClosing = true;
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.close, color: AppColors.black, size: 24.sp),
            onPressed: () => _close(PaymobWebViewResult.dismissed),
          ),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'market.payment_title'.tr(),
                style: TextStyleManager.style14Bold
                    .copyWith(color: AppColors.black),
              ),
              SizedBox(height: 2.h),
              Text(
                '${widget.amount.toStringAsFixed(2)} ${widget.currency}',
                style: TextStyleManager.style10Medium
                    .copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
          ],
        ),
      ),
    );
  }
}
