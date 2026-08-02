import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'failures.dart';

/// Turns a transport-level exception into a [Failure] the app can present.
///
/// Every message here is localized. They used to be hardcoded Arabic strings,
/// which meant an English-locale user saw Arabic error text anywhere the raw
/// `failure.message` reached the screen — and that is most places, since only
/// `AppErrorView` and `showAppError` substitute their own copy for network
/// failures. Fixing it at the source covers every path at once, including the
/// action snackbars that show the message verbatim.
///
/// The backend's own `message` is never translated — it arrives already in the
/// language named by the `lang` header.
class ErrorHandler {
  static Failure handle(dynamic error) {
    if (error is DioException) {
      return _handleDioError(error);
    } else {
      return ServerFailure(error.toString());
    }
  }

  static Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkFailure('errors.timeout'.tr());
      case DioExceptionType.badResponse:
        final response = error.response;
        if (response != null && response.data is Map) {
          final message = response.data['message'] ??
              response.data['error'] ??
              'errors.something_went_wrong'.tr();
          // Field-level validation errors carry the offending field in `key`
          // so the UI can show the message under that specific input.
          final key = response.data['key'];
          if (key is String && key.isNotEmpty) {
            return ValidationFailure(message.toString(), key);
          }
          return ServerFailure(message.toString());
        }
        return ServerFailure(
          'errors.server_status'.tr(args: ['${response?.statusCode}']),
        );
      case DioExceptionType.cancel:
        return ServerFailure('errors.request_cancelled'.tr());
      case DioExceptionType.connectionError:
        return NetworkFailure('errors.no_internet_subtitle'.tr());
      default:
        return ServerFailure('errors.generic_subtitle'.tr());
    }
  }
}
