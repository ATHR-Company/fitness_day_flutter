import 'package:dio/dio.dart';
import 'package:fitness_day/core/cache/app_cache.dart';
import 'package:fitness_day/core/cache/secure_cache.dart';
import 'package:fitness_day/core/network/api_service.dart';
import 'package:fitness_day/core/network/token_interceptor.dart';
import 'package:fitness_day/core/constant/api_endpoints.dart';

// Specialist Auth
import 'package:fitness_day/features/specialist/auth/data/datasources/auth_remote_datasource.dart';
import 'package:fitness_day/features/specialist/auth/data/repositories/auth_repository_impl.dart';
import 'package:fitness_day/features/specialist/auth/domain/repositories/auth_repository.dart';
import 'package:fitness_day/features/specialist/auth/domain/usecases/login_usecase.dart';
import 'package:fitness_day/features/specialist/auth/presentation/manager/auth_cubit.dart';

// User Auth & Registration Setup
import 'package:fitness_day/features/user/auth/data/datasources/user_auth_remote_datasource.dart';
import 'package:fitness_day/features/user/auth/data/repositories/user_auth_repository_impl.dart';
import 'package:fitness_day/features/user/auth/domain/repositories/user_auth_repository.dart';
import 'package:fitness_day/features/user/auth/domain/usecases/user_signup_usecase.dart';
import 'package:fitness_day/features/user/auth/domain/usecases/user_verify_otp_usecase.dart';
import 'package:fitness_day/features/user/auth/domain/usecases/get_user_lookups_usecase.dart';
import 'package:fitness_day/features/user/auth/domain/usecases/complete_personal_data_usecase.dart';
import 'package:fitness_day/features/user/auth/domain/usecases/get_health_questions_usecase.dart';
import 'package:fitness_day/features/user/auth/domain/usecases/submit_health_answers_usecase.dart';
import 'package:fitness_day/features/user/auth/domain/usecases/social_auth_usecase.dart';
import 'package:fitness_day/features/user/auth/domain/usecases/user_signin_usecase.dart';
import 'package:fitness_day/features/user/auth/domain/usecases/forgot_password_send_otp_usecase.dart';
import 'package:fitness_day/features/user/auth/domain/usecases/forgot_password_verify_otp_usecase.dart';
import 'package:fitness_day/features/user/auth/domain/usecases/forgot_password_reset_usecase.dart';
import 'package:fitness_day/features/user/auth/domain/usecases/forgot_password_resend_otp_usecase.dart';
import 'package:fitness_day/features/user/auth/presentation/manager/user_auth_cubit.dart';
import 'package:fitness_day/features/user/auth/presentation/manager/user_setup_cubit.dart';

// User Visits & Diet
import 'package:fitness_day/features/user/visits/data/datasources/visits_remote_datasource.dart';
import 'package:fitness_day/features/user/visits/data/repositories/visits_repository_impl.dart';
import 'package:fitness_day/features/user/visits/domain/repositories/visits_repository.dart';
import 'package:fitness_day/features/user/visits/domain/usecases/get_diet_plan_usecase.dart';
import 'package:fitness_day/features/user/visits/domain/usecases/get_meal_details_usecase.dart';
import 'package:fitness_day/features/user/visits/presentation/manager/diet_plan_cubit.dart';
import 'package:fitness_day/features/user/visits/presentation/manager/meal_details_cubit.dart';

// User Workouts
import 'package:fitness_day/features/user/workout/data/datasources/workout_remote_datasource.dart';
import 'package:fitness_day/features/user/workout/data/repositories/workout_repository_impl.dart';
import 'package:fitness_day/features/user/workout/domain/repositories/workout_repository.dart';
import 'package:fitness_day/features/user/workout/domain/usecases/get_workout_plan_usecase.dart';
import 'package:fitness_day/features/user/workout/domain/usecases/get_workout_details_usecase.dart';
import 'package:fitness_day/features/user/workout/domain/usecases/complete_workout_set_usecase.dart';
import 'package:fitness_day/features/user/workout/presentation/manager/workout_plan_cubit.dart';
import 'package:fitness_day/features/user/workout/presentation/manager/workout_details_cubit.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  // ═════════════════════════════════════════════════
  //                  EXTERNAL
  // ═════════════════════════════════════════════════

  await GetStorage.init();
  getIt.registerLazySingleton(() => GetStorage());
  getIt.registerLazySingleton(
    () => const FlutterSecureStorage(
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
      aOptions: AndroidOptions(),
    ),
  );

  // ═════════════════════════════════════════════════
  //                    CACHE
  // ═════════════════════════════════════════════════

  getIt.registerLazySingleton<AppCache>(
    () => AppCacheImpl(getIt<GetStorage>()),
  );
  getIt.registerLazySingleton<SecureCache>(
    () => SecureCacheImpl(getIt<FlutterSecureStorage>()),
  );

  // ═════════════════════════════════════════════════
  //                   NETWORK
  // ═════════════════════════════════════════════════

  getIt.registerLazySingleton<TokenInterceptor>(
    () => TokenInterceptor(getIt<SecureCache>()),
  );

  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        followRedirects: true,
        maxRedirects: 3,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // Add interceptors
    dio.interceptors.add(getIt<TokenInterceptor>());

    if (kDebugMode) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
        ),
      );
    }

    return dio;
  });

  getIt.registerLazySingleton<ApiService>(() => ApiService(getIt<Dio>()));

  // ═════════════════════════════════════════════════
  //                 DATA SOURCES
  // ═════════════════════════════════════════════════

  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(),
  );

  getIt.registerLazySingleton<UserAuthRemoteDataSource>(
    () => UserAuthRemoteDataSourceImpl(getIt<ApiService>()),
  );

  getIt.registerLazySingleton<VisitsRemoteDataSource>(
    () => VisitsRemoteDataSourceImpl(getIt<ApiService>()),
  );

  getIt.registerLazySingleton<WorkoutRemoteDataSource>(
    () => WorkoutRemoteDataSourceImpl(getIt<ApiService>()),
  );

  // ═════════════════════════════════════════════════
  //                 REPOSITORIES
  // ═════════════════════════════════════════════════

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      getIt<AuthRemoteDataSource>(),
    ),
  );

  getIt.registerLazySingleton<UserAuthRepository>(
    () => UserAuthRepositoryImpl(
      getIt<UserAuthRemoteDataSource>(),
    ),
  );

  getIt.registerLazySingleton<VisitsRepository>(
    () => VisitsRepositoryImpl(
      getIt<VisitsRemoteDataSource>(),
    ),
  );

  getIt.registerLazySingleton<WorkoutRepository>(
    () => WorkoutRepositoryImpl(
      getIt<WorkoutRemoteDataSource>(),
    ),
  );

  // ═════════════════════════════════════════════════
  //                 USE CASES
  // ═════════════════════════════════════════════════
  
  getIt.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<UserSignupUseCase>(
    () => UserSignupUseCase(getIt<UserAuthRepository>()),
  );

  getIt.registerLazySingleton<UserVerifyOtpUseCase>(
    () => UserVerifyOtpUseCase(getIt<UserAuthRepository>()),
  );

  getIt.registerLazySingleton<GetUserLookupsUseCase>(
    () => GetUserLookupsUseCase(getIt<UserAuthRepository>()),
  );

  getIt.registerLazySingleton<CompletePersonalDataUseCase>(
    () => CompletePersonalDataUseCase(getIt<UserAuthRepository>()),
  );

  getIt.registerLazySingleton<GetHealthQuestionsUseCase>(
    () => GetHealthQuestionsUseCase(getIt<UserAuthRepository>()),
  );

  getIt.registerLazySingleton<SubmitHealthAnswersUseCase>(
    () => SubmitHealthAnswersUseCase(getIt<UserAuthRepository>()),
  );

  getIt.registerLazySingleton<SocialAuthUseCase>(
    () => SocialAuthUseCase(getIt<UserAuthRepository>()),
  );

  getIt.registerLazySingleton<UserSigninUseCase>(
    () => UserSigninUseCase(getIt<UserAuthRepository>()),
  );

  getIt.registerLazySingleton<ForgotPasswordSendOtpUseCase>(
    () => ForgotPasswordSendOtpUseCase(getIt<UserAuthRepository>()),
  );

  getIt.registerLazySingleton<ForgotPasswordVerifyOtpUseCase>(
    () => ForgotPasswordVerifyOtpUseCase(getIt<UserAuthRepository>()),
  );

  getIt.registerLazySingleton<ForgotPasswordResetUseCase>(
    () => ForgotPasswordResetUseCase(getIt<UserAuthRepository>()),
  );

  getIt.registerLazySingleton<ForgotPasswordResendOtpUseCase>(
    () => ForgotPasswordResendOtpUseCase(getIt<UserAuthRepository>()),
  );

  getIt.registerLazySingleton<GetDietPlanUseCase>(
    () => GetDietPlanUseCase(getIt<VisitsRepository>()),
  );

  getIt.registerLazySingleton<GetMealDetailsUseCase>(
    () => GetMealDetailsUseCase(getIt<VisitsRepository>()),
  );

  getIt.registerLazySingleton<GetWorkoutPlanUseCase>(
    () => GetWorkoutPlanUseCase(getIt<WorkoutRepository>()),
  );

  getIt.registerLazySingleton<GetWorkoutDetailsUseCase>(
    () => GetWorkoutDetailsUseCase(getIt<WorkoutRepository>()),
  );

  getIt.registerLazySingleton<CompleteWorkoutSetUseCase>(
    () => CompleteWorkoutSetUseCase(getIt<WorkoutRepository>()),
  );

  // ═════════════════════════════════════════════════
  //                    BLoCs
  // ═════════════════════════════════════════════════

  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(loginUseCase: getIt<LoginUseCase>()),
  );

  getIt.registerFactory<UserAuthCubit>(
    () => UserAuthCubit(
      signupUseCase: getIt<UserSignupUseCase>(),
      verifyOtpUseCase: getIt<UserVerifyOtpUseCase>(),
      socialAuthUseCase: getIt<SocialAuthUseCase>(),
      signinUseCase: getIt<UserSigninUseCase>(),
      forgotPasswordSendOtpUseCase: getIt<ForgotPasswordSendOtpUseCase>(),
      forgotPasswordVerifyOtpUseCase: getIt<ForgotPasswordVerifyOtpUseCase>(),
      forgotPasswordResetUseCase: getIt<ForgotPasswordResetUseCase>(),
      forgotPasswordResendOtpUseCase: getIt<ForgotPasswordResendOtpUseCase>(),
      secureCache: getIt<SecureCache>(),
      appCache: getIt<AppCache>(),
    ),
  );

  getIt.registerFactory<UserSetupCubit>(
    () => UserSetupCubit(
      getUserLookupsUseCase: getIt<GetUserLookupsUseCase>(),
      completePersonalDataUseCase: getIt<CompletePersonalDataUseCase>(),
      getHealthQuestionsUseCase: getIt<GetHealthQuestionsUseCase>(),
      submitHealthAnswersUseCase: getIt<SubmitHealthAnswersUseCase>(),
      appCache: getIt<AppCache>(),
    ),
  );

  getIt.registerFactory<DietPlanCubit>(
    () => DietPlanCubit(
      getDietPlanUseCase: getIt<GetDietPlanUseCase>(),
    ),
  );

  getIt.registerFactory<MealDetailsCubit>(
    () => MealDetailsCubit(
      getMealDetailsUseCase: getIt<GetMealDetailsUseCase>(),
    ),
  );

  getIt.registerFactory<WorkoutPlanCubit>(
    () => WorkoutPlanCubit(
      getIt<GetWorkoutPlanUseCase>(),
    ),
  );

  getIt.registerFactory<WorkoutDetailsCubit>(
    () => WorkoutDetailsCubit(
      getWorkoutDetailsUseCase: getIt<GetWorkoutDetailsUseCase>(),
      completeWorkoutSetUseCase: getIt<CompleteWorkoutSetUseCase>(),
    ),
  );
}
