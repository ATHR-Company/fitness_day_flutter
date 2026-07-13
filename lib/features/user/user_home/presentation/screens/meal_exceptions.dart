/// Thrown when any meal analysis API call fails or returns an unexpected response.
class MealAnalysisException implements Exception {
  final String message;
  MealAnalysisException(this.message);
  @override
  String toString() => message;
}
