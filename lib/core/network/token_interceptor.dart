import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:fitness_day/core/cache/secure_cache.dart';
import 'package:fitness_day/core/constant/api_endpoints.dart';
import 'package:fitness_day/core/constant/app_locale.dart';
import 'package:fitness_day/core/services/session_manager.dart';

class TokenInterceptor extends Interceptor {
  /// Value the backend puts in `key` when the account was signed into on
  /// another device. Matched on instead of `message`, which is localized and
  /// free to be reworded.
  static const String _kSessionRevoked = 'session_revoked';

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

  /// Message carried by a `session_revoked` reply, held between the refresh
  /// attempt that hit it and the [onError] branch that reports it.
  ///
  /// A refresh answered with `session_revoked` is indistinguishable from a
  /// refresh that simply failed by the time [_performRefresh] returns null, and
  /// the two deserve different words on screen.
  String? _revokedDuringRefresh;

  /// True when a response is a 401 the session cannot come back from.
  ///
  /// Every other 401 means "this access token is stale" and is answered with a
  /// refresh. This one means the session itself is gone, so refreshing would
  /// only ask the server to say no again.
  bool _isSessionRevoked(Response<dynamic>? response) {
    if (response?.statusCode != 401) return false;
    final dynamic data = response?.data;
    return data is Map && data['key'] == _kSessionRevoked;
  }

  String? _messageOf(Response<dynamic>? response) {
    final dynamic data = response?.data;
    if (data is Map && data['message'] is String) return data['message'] as String;
    return null;
  }

  /// The session can no longer be authenticated — clear all local session state
  /// and send the user back to role selection.
  Future<void> _endSession(SessionEndReason reason, {String? serverMessage}) {
    return GetIt.instance<SessionManager>().endSession(
      reason: reason,
      serverMessage: serverMessage,
    );
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
      // A refresh refused with `session_revoked` is not a failed refresh — the
      // account moved to another device. Remember it so the caller can say so.
      if (e is DioException && _isSessionRevoked(e.response)) {
        _revokedDuringRefresh = _messageOf(e.response) ?? '';
      }
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
      // Checked before anything else: this 401 is terminal, and running it
      // through the refresh path would burn a round trip to be told the same.
      if (_isSessionRevoked(err.response)) {
        await _endSession(
          SessionEndReason.loggedInElsewhere,
          serverMessage: _messageOf(err.response),
        );
        return super.onError(err, handler);
      }

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
      final String? revoked = _revokedDuringRefresh;
      _revokedDuringRefresh = null;
      await _endSession(
        revoked != null
            ? SessionEndReason.loggedInElsewhere
            : SessionEndReason.expired,
        serverMessage: revoked,
      );
    }
    super.onError(err, handler);
  }
}
