import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:fitness_day/core/cache/app_cache.dart';
import 'package:fitness_day/core/cache/secure_cache.dart';
import 'package:fitness_day/core/constant/api_endpoints.dart';
import 'package:fitness_day/core/constant/app_locale.dart';
import 'package:fitness_day/core/routes/app_router.dart';
import 'package:fitness_day/core/routes/shared/shared_routes.dart';
import 'package:fitness_day/core/services/socket_service.dart';
import 'package:fitness_day/fitness_day.dart';

class TokenInterceptor extends Interceptor {
  final SecureCache _secureCache;

  TokenInterceptor(this._secureCache);

  // Ensures concurrent 401s / proactive-refresh checks share a single
  // in-flight refresh call instead of each racing the (often single-use,
  // rotating) refresh token — a losing racer would otherwise wipe the
  // valid token the winner just saved.
  Future<String?>? _refreshFuture;

  Future<String?> _refreshSingleFlight() {
    return _refreshFuture ??= _refreshFromStoredToken().whenComplete(() {
      _refreshFuture = null;
    });
  }

  Future<String?> _refreshFromStoredToken() async {
    final refreshToken = await _secureCache.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return null;
    return _performRefresh(refreshToken);
  }

  /// The session can no longer be authenticated (no refresh token, or the
  /// backend rejected it) — clear all local session state and send the user
  /// back to role selection so they can log in again.
  Future<void> _handleSessionExpired() async {
    // The socket authenticates with the same token, so an expired session must
    // close it too — otherwise it keeps retrying against a dead session.
    try {
      GetIt.instance<SocketService>().disconnect();
    } catch (_) {}
    await _secureCache.deleteToken();
    await _secureCache.deleteRefreshToken();
    try {
      await GetIt.instance<AppCache>().clear();
    } catch (_) {}
    RoleNotifier.instance.setRole(AppRole.none);

    final context = AppRouter.navigatorKey.currentContext;
    if (context != null) {
      context.go(SharedRoutes.roleSelection);
    }
  }

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
    // Add language header from the live AppLocale singleton
    options.headers['lang'] = AppLocale.langCode;

    var token = await _secureCache.getToken();
    if (token != null && token.isNotEmpty) {
      if (_isTokenExpired(token)) {
        final newToken = await _refreshSingleFlight();
        if (newToken != null) {
          token = newToken;
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
      final currentRefreshToken = await _secureCache.getRefreshToken();
      if (currentRefreshToken != null && currentRefreshToken.isNotEmpty) {
        final newAccessToken = await _refreshSingleFlight();
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
      // Reached only when there was no refresh token, or the refresh
      // attempt itself failed — the session is unrecoverable.
      await _handleSessionExpired();
    }
    super.onError(err, handler);
  }
}
