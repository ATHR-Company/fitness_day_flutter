import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:fitness_day/core/cache/secure_cache.dart';
import 'package:fitness_day/core/constant/api_endpoints.dart';

class TokenInterceptor extends Interceptor {
  final SecureCache _secureCache;

  TokenInterceptor(this._secureCache);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureCache.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      final refreshToken = await _secureCache.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          // Attempt token refresh using a separate Dio instance to avoid interceptor loop
          final dioClient = Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl));
          final response = await dioClient.post(
            ApiEndpoints.authRefresh,
            data: {'refreshToken': refreshToken},
          );

          if (response.statusCode == 200 && response.data != null) {
            final newAccessToken = response.data['data']['accessToken'];
            final newRefreshToken = response.data['data']['refreshToken'];
            
            await _secureCache.saveToken(newAccessToken);
            if (newRefreshToken != null) {
              await _secureCache.saveRefreshToken(newRefreshToken);
            }

            // Retry original request lazily resolving Dio to prevent DI cycle
            final dio = GetIt.instance<Dio>();
            final requestOptions = err.requestOptions;
            requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
            
            final clone = await dio.request(
              requestOptions.path,
              data: requestOptions.data,
              queryParameters: requestOptions.queryParameters,
              options: Options(
                method: requestOptions.method,
                headers: requestOptions.headers,
              ),
            );
            return handler.resolve(clone);
          }
        } catch (e) {
          // If refresh fails, clear cache/logout and proceed with error
          await _secureCache.deleteToken();
          await _secureCache.deleteRefreshToken();
        }
      }
    }
    super.onError(err, handler);
  }
}
