/// Lifecycle of a Paymob payment, as reported by
/// `GET /payments/paymob/orders/:id/status`.
///
/// The backend is the only authority here — the Paymob web page showing a
/// success screen means nothing until the status endpoint says [completed].
enum PaymentStatus {
  /// Not resolved yet — keep polling.
  pending,

  /// The result is being applied right now — keep polling.
  processing,

  /// Paid and fulfilled. The only state that may show a success screen.
  completed,

  /// Declined. See `failureReason`.
  failed,

  /// Superseded by a newer attempt — call initiate again.
  cancelled,

  /// A status string the app doesn't know. Treated like [pending] so a future
  /// backend value can never be mistaken for a failure.
  unknown;

  static PaymentStatus fromApi(String? raw) {
    return switch (raw?.toUpperCase()) {
      'PENDING' => PaymentStatus.pending,
      'PROCESSING' => PaymentStatus.processing,
      'COMPLETED' => PaymentStatus.completed,
      'FAILED' => PaymentStatus.failed,
      'CANCELLED' => PaymentStatus.cancelled,
      _ => PaymentStatus.unknown,
    };
  }

  /// True while the result is still in flight.
  bool get isPending =>
      this == PaymentStatus.pending ||
      this == PaymentStatus.processing ||
      this == PaymentStatus.unknown;
}

/// Result of `POST /payments/paymob/orders/:id/initiate`.
class PaymentInitiation {
  final String paymentIdentity;
  final String orderIdentity;
  final PaymentStatus status;

  /// What the buyer is about to be charged. Locked server-side at this point —
  /// a coupon applied afterwards will not change it.
  final double amount;
  final String currency;

  /// The hosted Paymob page to open in the WebView. This is the whole job.
  final String webviewUrl;

  /// Only needed if we ever swap the WebView for Paymob's own SDK.
  final String? clientSecret;
  final String? intentionId;

  /// The checkout dies one hour after initiate; past this, initiate again.
  final DateTime? expiresAt;

  const PaymentInitiation({
    required this.paymentIdentity,
    required this.orderIdentity,
    required this.status,
    required this.amount,
    required this.currency,
    required this.webviewUrl,
    this.clientSecret,
    this.intentionId,
    this.expiresAt,
  });

  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);
}

/// Result of `GET /payments/paymob/orders/:id/status` — the source of truth.
class PaymentStatusData {
  final String paymentIdentity;
  final String orderIdentity;
  final PaymentStatus status;
  final double amount;
  final String currency;
  final DateTime? paidAt;

  /// Populated when [status] is [PaymentStatus.failed]; already translated to
  /// the `lang` header that was sent.
  final String? failureReason;

  final DateTime? expiresAt;

  const PaymentStatusData({
    required this.paymentIdentity,
    required this.orderIdentity,
    required this.status,
    required this.amount,
    required this.currency,
    this.paidAt,
    this.failureReason,
    this.expiresAt,
  });
}
