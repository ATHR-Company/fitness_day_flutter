import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/cache/secure_cache.dart';
import 'package:fitness_day/core/cache/app_cache.dart';
import 'package:fitness_day/features/specialist/auth/domain/usecases/login_usecase.dart';
import 'package:fitness_day/features/specialist/auth/domain/usecases/logout_usecase.dart';
import 'package:fitness_day/features/specialist/auth/presentation/manager/auth_state.dart';
import 'package:fitness_day/fitness_day.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final SecureCache secureCache;
  final AppCache appCache;

  AuthCubit({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.secureCache,
    required this.appCache,
  }) : super(AuthInitial());

  Future<void> login(String phone, String password) async {
    emit(AuthLoading());
    final result = await loginUseCase.call(phone, password);
    await result.fold(
      (failure) async {
        emit(AuthFailure(failure));
      },
      (user) async {
        await secureCache.saveToken(user.token);
        await secureCache.saveRefreshToken(user.refreshToken);
        await appCache.saveUserType('specialist');
        await appCache.saveIsLoggedIn(true);
        emit(AuthSuccess(user));
      },
    );
  }

  Future<void> logout() async {
    emit(AuthLoading());
    await logoutUseCase.call();
    await secureCache.deleteToken();
    await secureCache.deleteRefreshToken();
    await appCache.clear();
    RoleNotifier.instance.setRole(AppRole.none);
    emit(AuthLoggedOut());
  }
}
