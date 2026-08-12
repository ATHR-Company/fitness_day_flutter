import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// A 4xx response that names the field it rejected, e.g.
/// `{"message": "dailyMeals must not be greater than 10", "key": "DAILY_MEALS"}`.
///
/// [key] is the raw backend key; screens map it to the input that should show
/// the message underneath it.
class ValidationFailure extends ServerFailure {
  final String key;

  const ValidationFailure(super.message, this.key);

  @override
  List<Object?> get props => [message, key];
}

/// A 429 that says when the caller may try again, e.g.
/// `{"message": "Wait a moment before requesting a new code.",
///   "retryAfterSeconds": 59}`.
///
/// Distinct from a plain [ServerFailure] because the screen can do something
/// with it: count the seconds down on the button instead of only apologising.
class RateLimitFailure extends ServerFailure {
  final int retryAfterSeconds;

  const RateLimitFailure(super.message, this.retryAfterSeconds);

  @override
  List<Object?> get props => [message, retryAfterSeconds];
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}
