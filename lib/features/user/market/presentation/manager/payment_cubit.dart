import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fitness_day/core/cache/app_cache.dart';
import 'package:fitness_day/core/errors/failures.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/core/utils/money_format.dart';
import '../../domain/entities/order_data.dart';
import '../../domain/entities/payment_data.dart';
import '../../domain/usecases/get_payment_status_usecase.dart';
import '../../domain/usecases/initiate_payment_usecase.dart';
import 'package:fitness_day/core/errors/app_error.dart';

part 'payment_state.dart';

/// Drives the Paymob flow: initiate → WebView → confirm with the backend.
///
/// The rule this class exists to enforce: **the WebView is never the source of
/// truth.** Whatever the hosted page displays, the only thing that decides
/// whether an order is paid is the status endpoint, because only the backend
/// receives Paymob's signed server-to-server callback.
class PaymentCubit extends Cubit<PaymentState> {
  /// The result almost always lands within a few seconds of the buyer
  /// confirming; 60s of polling is generous headroom.
  static const Duration _pollInterval = Duration(seconds: 2);
  static const Duration _pollTimeout = Duration(seconds: 60);

  final InitiatePaymentUseCase _initiatePaymentUseCase;
  final GetPaymentStatusUseCase _getPaymentStatusUseCase;
  final AppCache _appCache;

  PaymentCubit({
    required InitiatePaymentUseCase initiatePaymentUseCase,
    required GetPaymentStatusUseCase getPaymentStatusUseCase,
    required AppCache appCache,
  })  : _initiatePaymentUseCase = initiatePaymentUseCase,
        _getPaymentStatusUseCase = getPaymentStatusUseCase,
        _appCache = appCache,
        super(const PaymentInitial());

  String? _orderIdentity;
  bool _isPolling = false;

  /// The order this cubit is currently paying for.
  String? get orderIdentity => _orderIdentity;

  // ── Step 4: open the checkout ──────────────────────────────────────────────

  /// Opens a Paymob checkout for [orderIdentity].
  ///
  /// Call this only after every coupon / delivery change has been applied —
  /// the charged amount is locked server-side from here on.
  ///
  /// Idempotent by design: the backend hands back the same checkout when the
  /// price is unchanged, so a buyer tapping "Pay" twice is harmless.
  Future<void> startPayment(String orderIdentity) async {
    _orderIdentity = orderIdentity;
    emit(const PaymentInitiating());

    final result = await _initiatePaymentUseCase(orderIdentity);

    switch (result) {
      case Success(:final data):
        // Whatever the backend is settling in right now — it switches markets
        // by config, so the app follows rather than assumes.
        AppCurrency.set(data.currency);
        // Remembered before the WebView opens, so a kill mid-payment still
        // leaves a trail to resume from on the next launch.
        await _appCache.savePendingPaymentOrderId(orderIdentity);
        emit(PaymentWebviewReady(data));
      case FailureResult(:final failure):
        emit(PaymentError(failure.message, error: AppError.from(failure)));
    }
  }

  /// Resumes an order whose checkout the backend already reported in
  /// `GET /orders` — no `initiate` needed, the link is live.
  ///
  /// Every `initiate` registers a real intention with Paymob, so reusing the
  /// reported checkout is what keeps abandoned transactions out of their
  /// dashboard. An expired or empty link falls back to [startPayment].
  Future<void> startPaymentWithExistingCheckout(
    String orderIdentity,
    OrderPaymentData payment,
  ) async {
    if (!payment.isUsable) return startPayment(orderIdentity);

    _orderIdentity = orderIdentity;
    AppCurrency.set(payment.currency);
    await _appCache.savePendingPaymentOrderId(orderIdentity);

    emit(PaymentWebviewReady(PaymentInitiation(
      paymentIdentity: payment.paymentIdentity,
      orderIdentity: orderIdentity,
      status: PaymentStatus.pending,
      amount: payment.amount,
      currency: payment.currency,
      webviewUrl: payment.webviewUrl,
      expiresAt: payment.expiresAt,
    )));
  }

  // ── Step 6: confirm with the backend ───────────────────────────────────────

  /// Polls the status endpoint until the payment resolves.
  ///
  /// Called when the WebView closes — for *any* reason. A buyer dismissing the
  /// page is not a cancellation: they may well have paid and then closed it.
  Future<void> confirmPayment([String? orderIdentity]) async {
    final String? target = orderIdentity ?? _orderIdentity;
    if (target == null || _isPolling) return;

    _orderIdentity = target;
    _isPolling = true;
    try {
      await _pollUntilResolved(target);
    } finally {
      _isPolling = false;
    }
  }

  /// Settles the flow after the buyer *dismissed* the checkout themselves.
  ///
  /// One status check, no polling. Backing out of the page is not an event the
  /// backend is about to resolve, so sitting on a 60-second poll would only
  /// freeze the screen on an order that is plainly still unpaid.
  ///
  /// The single check is still worth making: a buyer can pay and *then* close
  /// the page, and that has to come back as [PaymentCompleted]. Anything not
  /// yet resolved is reported as [PaymentNotCompleted] — the order stays
  /// payable and the buyer can start a fresh attempt whenever they want.
  Future<void> confirmAfterDismiss([String? orderIdentity]) async {
    final String? target = orderIdentity ?? _orderIdentity;
    if (target == null || _isPolling) return;

    _orderIdentity = target;
    _isPolling = true;
    try {
      emit(const PaymentConfirming());
      final result = await _getPaymentStatusUseCase(target);
      if (isClosed) return;

      switch (result) {
        case Success(:final data):
          if (await _applyResolvedStatus(data)) return;
        case FailureResult():
          // No verdict available. Treating that as "still unpaid" is the safe
          // read — the order keeps its real status on the server either way.
          break;
      }

      if (isClosed) return;
      // Nothing to keep waiting on, so the resume-on-launch marker goes too.
      await _appCache.clearPendingPaymentOrderId();
      emit(const PaymentNotCompleted());
    } finally {
      _isPolling = false;
    }
  }

  /// Settles the flow after Paymob's page reported the transaction declined.
  ///
  /// The decline was seen on the hosted page, so the verdict is not in doubt —
  /// this only asks the backend so the buyer gets its exact reason when the
  /// callback has already landed. Unresolved after one check still reports a
  /// failure, because the page said so.
  Future<void> confirmAfterDecline([String? orderIdentity]) async {
    final String? target = orderIdentity ?? _orderIdentity;
    if (target == null || _isPolling) return;

    _orderIdentity = target;
    _isPolling = true;
    try {
      emit(const PaymentConfirming());
      final result = await _getPaymentStatusUseCase(target);
      if (isClosed) return;

      if (result case Success(:final data)) {
        if (await _applyResolvedStatus(data)) return;
      }

      if (isClosed) return;
      await _appCache.clearPendingPaymentOrderId();
      emit(const PaymentFailed('market.payment_failed_generic'));
    } finally {
      _isPolling = false;
    }
  }

  Future<void> _pollUntilResolved(String orderIdentity) async {
    final DateTime deadline = DateTime.now().add(_pollTimeout);
    int attempt = 0;

    while (!isClosed && DateTime.now().isBefore(deadline)) {
      emit(PaymentConfirming(attempt: attempt));
      attempt++;

      final result = await _getPaymentStatusUseCase(orderIdentity);
      if (isClosed) return;

      switch (result) {
        case Success(:final data):
          if (await _applyResolvedStatus(data)) return;

        case FailureResult(:final failure):
          // A dropped connection is not a verdict — keep trying until the
          // deadline. Anything else (404 = initiate never ran, and other
          // rejections) is terminal.
          if (failure is! NetworkFailure) {
            emit(PaymentError(failure.message, error: AppError.from(failure)));
            return;
          }
          debugPrint('[PaymentCubit] status poll failed, retrying: '
              '${failure.message}');
      }

      await Future.delayed(_pollInterval);
    }

    if (isClosed) return;

    // Out of time and still unresolved. The backend will finish it on its own,
    // so the buyer is told to wait — never that the payment failed.
    emit(const PaymentAwaitingConfirmation());
  }

  /// Emits the terminal state for [data], returning true when polling is done.
  Future<bool> _applyResolvedStatus(PaymentStatusData data) async {
    AppCurrency.set(data.currency);

    switch (data.status) {
      case PaymentStatus.completed:
        await _appCache.clearPendingPaymentOrderId();
        emit(PaymentCompleted(data));
        return true;

      case PaymentStatus.failed:
        await _appCache.clearPendingPaymentOrderId();
        emit(PaymentFailed(
          data.failureReason ?? 'market.payment_failed_generic',
        ));
        return true;

      case PaymentStatus.cancelled:
        // Superseded by a newer attempt — the way forward is a fresh initiate,
        // so the pending marker stays put.
        emit(const PaymentFailed(
          'market.payment_cancelled_retry',
          isRetryable: true,
        ));
        return true;

      case PaymentStatus.pending:
      case PaymentStatus.processing:
      case PaymentStatus.unknown:
        if (data.expiresAt != null && DateTime.now().isAfter(data.expiresAt!)) {
          await _appCache.clearPendingPaymentOrderId();
          return true;
        }
        return false;
    }
  }

  // ── Resuming after the app was killed ──────────────────────────────────────

  /// Picks up a payment this device started but never saw resolve.
  ///
  /// **Single-shot only** — intentionally not a full 60-second poll.
  ///
  /// Rationale: this runs silently on every app open via [PendingPaymentWatcher].
  /// If we ran the full poll loop here, every launch would hammer the status
  /// endpoint for up to a minute. Instead we do one check:
  ///
  /// - Resolved (COMPLETED / FAILED / CANCELLED) → emit the result, clear marker.
  /// - Still PENDING / PROCESSING                → **clear the marker silently**.
  ///   The order still exists on the server; if the user wants to pay they
  ///   go to the Orders screen and tap "Complete payment" — that re-enters
  ///   the full flow. We don't keep polling in the background.
  /// - Network error / any other failure         → clear marker, stay silent.
  Future<void> resumePendingPayment() async {
    final String? pending = _appCache.getPendingPaymentOrderId();
    if (pending == null || pending.isEmpty || _isPolling) return;

    debugPrint('[PaymentCubit] resume check for order $pending');

    final result = await _getPaymentStatusUseCase(pending);
    if (isClosed) return;

    switch (result) {
      case Success(:final data):
        AppCurrency.set(data.currency);
        final resolved = await _applyResolvedStatus(data);
        if (!resolved) {
          // Still PENDING/PROCESSING — silently forget the marker.
          // The user can retry from the Orders screen.
          await _appCache.clearPendingPaymentOrderId();
        }
      case FailureResult():
        // Network error or order not found — clear so we don't retry forever.
        await _appCache.clearPendingPaymentOrderId();
    }
  }

  /// Drops the pending marker without waiting for a verdict — used when the
  /// buyer explicitly abandons the order.
  Future<void> forgetPendingPayment() async {
    await _appCache.clearPendingPaymentOrderId();
  }

  /// Back to a clean slate so the same cubit can drive a retry.
  void reset() {
    if (isClosed) return;
    emit(const PaymentInitial());
  }
}
