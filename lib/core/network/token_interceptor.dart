import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:fitness_day/core/cache/secure_cache.dart';
import 'package:fitness_day/core/constant/api_endpoints.dart';

class TokenInterceptor extends Interceptor {
  final SecureCache _secureCache;

  TokenInterceptor(this._secureCache);

  bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final String decoded = utf8.decode(base64Url.decode(normalized));
      final Map<String, dynamic> json = jsonDecode(decoded);

      if (!json.containsKey('exp')) return false;
      final exp = json['exp'] as int;
      final expDateTime = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      // Proactively refresh if the token expires in the next 10 seconds
      return DateTime.now().isAfter(expDateTime.subtract(const Duration(seconds: 10)));
    } catch (_) {
      return true; // If parsing fails, consider it expired to force refresh/retry
    }
  }

  Future<String?> _performRefresh(String refreshToken) async {
    try {
      final dioClient = Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl));
      final response = await dioClient.post(
        ApiEndpoints.authRefresh,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final newAccessToken = response.data['data']['accessToken'] as String?;
        final newRefreshToken = response.data['data']['refreshToken'] as String?;

        if (newAccessToken != null) {
          await _secureCache.saveToken(newAccessToken);
          if (newRefreshToken != null) {
            await _secureCache.saveRefreshToken(newRefreshToken);
          }
          return newAccessToken;
        }
      }
    } catch (e) {
      // Refresh failed, clean tokens to prevent infinite refresh cycles
      await _secureCache.deleteToken();
      await _secureCache.deleteRefreshToken();
    }
    return null;
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    var token = await _secureCache.getToken();
    if (token != null && token.isNotEmpty) {
      if (_isTokenExpired(token)) {
        final refreshToken = await _secureCache.getRefreshToken();
        if (refreshToken != null && refreshToken.isNotEmpty) {
          final newToken = await _performRefresh(refreshToken);
          if (newToken != null) {
            token = newToken;
          }
        }
      }
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
        final newAccessToken = await _performRefresh(refreshToken);
        if (newAccessToken != null) {
          // Retry original request lazily resolving Dio to prevent DI cycle
          final dio = GetIt.instance<Dio>();
          final requestOptions = err.requestOptions;
          requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

          try {
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
          } catch (e) {
            return handler.next(DioException(
              requestOptions: requestOptions,
              error: e,
            ));
          }
        }
      }
    }
    super.onError(err, handler);
  }
}
