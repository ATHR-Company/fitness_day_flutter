/// Thrown when a meal-analysis call fails or returns something unusable.
///
/// The exception carries a translation *key* rather than finished copy, so the
/// services stay free of localisation and the screen decides how to phrase the
/// failure. Resolve it with `e.messageKey.tr(namedArgs: e.args)`.
class MealAnalysisException implements Exception {
  final String messageKey;

  /// Values interpolated into [messageKey], e.g. `{'code': '429'}`.
  final Map<String, String> args;

  const MealAnalysisException(this.messageKey, {this.args = const {}});

  /// The API key is missing from `.env` / `--dart-define` — a setup problem,
  /// not a server one.
  const MealAnalysisException.missingApiKey()
      : messageKey = 'scan_meal.errors.missing_api_key',
        args = const {};

  const MealAnalysisException.connectionFailed()
      : messageKey = 'scan_meal.errors.connection_failed',
        args = const {};

  const MealAnalysisException.rateLimited()
      : messageKey = 'scan_meal.errors.rate_limited',
        args = const {};

  MealAnalysisException.requestFailed(int statusCode)
      : messageKey = 'scan_meal.errors.request_failed',
        args = {'code': '$statusCode'};

  /// The model answered, but the body wasn't the JSON we asked for.
  const MealAnalysisException.unreadableResponse()
      : messageKey = 'scan_meal.errors.unreadable_response',
        args = const {};

  @override
  String toString() => 'MealAnalysisException($messageKey, $args)';
}
