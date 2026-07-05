import 'package:dio/dio.dart';
import 'failures.dart';

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
        return const NetworkFailure('خطأ في الاتصال بالخادم. يرجى المحاولة مرة أخرى.');
      case DioExceptionType.badResponse:
        final response = error.response;
        if (response != null && response.data is Map) {
          final message = response.data['message'] ?? response.data['error'] ?? 'حدث خطأ ما';
          return ServerFailure(message.toString());
        }
        return ServerFailure('حدث خطأ في الخادم (رمز الحالة: ${response?.statusCode})');
      case DioExceptionType.cancel:
        return const ServerFailure('تم إلغاء الطلب.');
      case DioExceptionType.connectionError:
        return const NetworkFailure('لا يوجد اتصال بالإنترنت. يرجى التحقق من الشبكة.');
      default:
        return const ServerFailure('حدث خطأ غير متوقع. يرجى المحاولة لاحقاً.');
    }
  }
}
