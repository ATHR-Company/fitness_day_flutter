import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/cache/secure_cache.dart';
import 'package:fitness_day/core/cache/app_cache.dart';
import 'package:fitness_day/features/specialist/auth/domain/usecases/login_usecase.dart';
import 'package:fitness_day/features/specialist/auth/presentation/manager/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final SecureCache secureCache;
  final AppCache appCache;

  AuthCubit({
    required this.loginUseCase,
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
        await appCache.saveIsLoggedIn(true);
        emit(AuthSuccess(user));
      },
    );
  }
}
