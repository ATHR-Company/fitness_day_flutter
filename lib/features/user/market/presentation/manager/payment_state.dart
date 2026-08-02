part of 'payment_cubit.dart';

sealed class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

/// Calling `initiate` — the buyer tapped pay but the checkout isn't open yet.
class PaymentInitiating extends PaymentState {
  const PaymentInitiating();
}

/// The checkout is open; the screen should push the WebView with [webviewUrl].
class PaymentWebviewReady extends PaymentState {
  final PaymentInitiation initiation;

  const PaymentWebviewReady(this.initiation);

  @override
  List<Object?> get props => [initiation.paymentIdentity, initiation.webviewUrl];
}

/// Polling the status endpoint. Entered after the WebView closes for any
/// reason — including the buyer dismissing it, which is never assumed to mean
/// "cancelled".
class PaymentConfirming extends PaymentState {
  /// How many polls have run, so the UI can hint that it is taking a while.
  final int attempt;

  const PaymentConfirming({this.attempt = 0});

  @override
  List<Object?> get props => [attempt];
}

/// The backend confirmed the payment. The only state allowed to show success.
class PaymentCompleted extends PaymentState {
  final PaymentStatusData payment;

  const PaymentCompleted(this.payment);

  @override
  List<Object?> get props => [payment.paymentIdentity, payment.status];
}

/// The payment was declined. [message] is the backend's `failureReason`,
/// already translated to the `lang` that was sent.
class PaymentFailed extends PaymentState {
  final String message;

  /// True when the backend says the attempt was superseded (`CANCELLED`), in
  /// which case retrying just means initiating again.
  final bool isRetryable;

  const PaymentFailed(this.message, {this.isRetryable = true});

  @override
  List<Object?> get props => [message, isRetryable];
}

/// The buyer closed the checkout without paying, and one check confirmed the
/// order is still unpaid.
///
/// Distinct from [PaymentAwaitingConfirmation]: nothing is in flight here, so
/// there is nothing to wait for. The order simply stays payable.
class PaymentNotCompleted extends PaymentState {
  const PaymentNotCompleted();
}

/// Polling ran out of time while the payment was still unresolved.
///
/// This is deliberately **not** a failure: the backend will still finish it.
/// Telling a buyer their payment failed when it actually succeeded is far
/// worse than telling them to wait.
class PaymentAwaitingConfirmation extends PaymentState {
  const PaymentAwaitingConfirmation();
}

/// The flow could not start at all (order missing, Paymob unreachable, …).
/// [message] comes from the backend envelope and is shown as-is.
class PaymentError extends PaymentState {
  final String message;

  /// Typed form of the failure, so the screen can decide between a
  /// full-screen retry and a message. Null on states not yet migrated.
  final AppError? error;

  const PaymentError(this.message, {this.error});

  @override
  List<Object?> get props => [message, error];
}
