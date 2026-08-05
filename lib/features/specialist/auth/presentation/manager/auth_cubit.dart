import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/cache/secure_cache.dart';
import 'package:fitness_day/core/cache/app_cache.dart';
import 'package:fitness_day/core/network/device_type_helper.dart';
import 'package:fitness_day/core/network/fcm_helper.dart';
import 'package:fitness_day/core/services/socket_service.dart';
import 'package:fitness_day/features/specialist/auth/domain/usecases/login_usecase.dart';
import 'package:fitness_day/features/specialist/auth/domain/usecases/logout_usecase.dart';
import 'package:fitness_day/features/specialist/auth/presentation/manager/auth_state.dart';
import 'package:fitness_day/fitness_day.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final SecureCache secureCache;
  final AppCache appCache;
  final SocketService socketService;

  AuthCubit({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.secureCache,
    required this.appCache,
    required this.socketService,
  }) : super(AuthInitial());

  Future<void> login(String phone, String password) async {
    emit(AuthLoading());
    final fcmToken = await FcmHelper.tokenForAuthRequest();
    final result = await loginUseCase.call(
      phone,
      password,
      fcmToken: fcmToken,
      deviceType: DeviceTypeHelper.current,
    );
    await result.fold(
      (failure) async {
        emit(AuthFailure(failure));
      },
      (user) async {
        await secureCache.saveToken(user.token);
        await secureCache.saveRefreshToken(user.refreshToken);
        await appCache.saveUserType('specialist');
        await appCache.saveIsLoggedIn(true);
        await socketService.connectWithStoredToken();
        emit(AuthSuccess(user));
      },
    );
  }

  Future<String?> logout() async {
    emit(AuthLoading());
    final result = await logoutUseCase.call();

    final String? errorMessage = result.fold(
      (failure) => failure,
      (_) => null,
    );

    if (errorMessage != null) {
      // API failed (e.g. no internet) — do NOT clear local session.
      emit(AuthInitial());
      return errorMessage;
    }

    // Before the token is dropped: the socket was left open on the previous
    // user's session, so it kept receiving their chat events after sign-out.
    socketService.disconnect();
    await secureCache.deleteToken();
    await secureCache.deleteRefreshToken();
    await appCache.clearSession();
    RoleNotifier.instance.setRole(AppRole.none);
    emit(AuthLoggedOut());
    return null;
  }
}
