import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/routes/specialist_routes/app_router.dart';
import 'package:fitness_day/core/routes/user_routes/app_router.dart';
import 'package:fitness_day/core/theme/app_text_styles.dart';
import 'package:fitness_day/features/specialist/auth/data/datasources/auth_remote_datasource.dart';
import 'package:fitness_day/features/specialist/auth/data/repositories/auth_repository_impl.dart';
import 'package:fitness_day/features/specialist/auth/domain/usecases/login_usecase.dart';
import 'package:fitness_day/features/specialist/auth/presentation/manager/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The active role for the current session.
/// Set this before calling [runApp] or via [FitnessDayApp.setRole].
enum AppRole { none, user, specialist }

/// Global notifier — role_selection_page calls [RoleNotifier.set] after the
/// user picks a role, which rebuilds [FitnessDay] with the correct router.
class RoleNotifier extends ValueNotifier<AppRole> {
  RoleNotifier() : super(AppRole.none);

  static final instance = RoleNotifier();

  void setRole(AppRole role) => value = role;
}

class FitnessDay extends StatelessWidget {
  const FitnessDay({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return BlocProvider(
          create: (context) => AuthCubit(
            loginUseCase: LoginUseCase(
              AuthRepositoryImpl(
                AuthRemoteDataSourceImpl(),
              ),
            ),
          ),
          // Listen to role changes and swap the router accordingly
          child: ValueListenableBuilder<AppRole>(
            valueListenable: RoleNotifier.instance,
            builder: (context, role, _) {
              final routerConfig = role == AppRole.user
                  ? UserAppRouter.router
                  : SpecialistAppRouter.router;

              return MaterialApp.router(
                title: 'Fitness Day',
                debugShowCheckedModeBanner: false,
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                locale: context.locale,
                theme: ThemeData(
                  colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
                  fontFamily: TextStyleManager.fontFamily,
                ),
                routerConfig: routerConfig,
              );
            },
          ),
        );
      },
    );
  }
}
