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
import 'package:fitness_day/features/specialist/auth/domain/usecases/logout_usecase.dart';
import 'package:fitness_day/features/specialist/auth/presentation/manager/auth_cubit.dart';

// Specialist Home
import 'package:fitness_day/features/specialist/home/data/datasources/specialist_home_remote_datasource.dart';
import 'package:fitness_day/features/specialist/home/data/repositories/specialist_home_repository_impl.dart';
import 'package:fitness_day/features/specialist/home/domain/repositories/specialist_home_repository.dart';
import 'package:fitness_day/features/specialist/home/domain/usecases/get_specialist_home_data_usecase.dart';
import 'package:fitness_day/features/specialist/home/presentation/manager/specialist_home_cubit.dart';

// Specialist Profile
import 'package:fitness_day/features/specialist/profile/data/datasources/specialist_profile_remote_datasource.dart';
import 'package:fitness_day/features/specialist/profile/data/repositories/specialist_profile_repository_impl.dart';
import 'package:fitness_day/features/specialist/profile/domain/repositories/specialist_profile_repository.dart';
import 'package:fitness_day/features/specialist/profile/domain/usecases/get_specialist_profile_usecase.dart';
import 'package:fitness_day/features/specialist/profile/domain/usecases/update_specialist_profile_usecase.dart';
import 'package:fitness_day/features/specialist/profile/presentation/manager/specialist_profile_cubit.dart';

// Specialist Clients
import 'package:fitness_day/features/specialist/clients/data/datasources/specialist_clients_remote_datasource.dart';
import 'package:fitness_day/features/specialist/clients/data/repositories/specialist_clients_repository_impl.dart';
import 'package:fitness_day/features/specialist/clients/domain/repositories/specialist_clients_repository.dart';
import 'package:fitness_day/features/specialist/clients/domain/usecases/get_specialist_clients_usecase.dart';
import 'package:fitness_day/features/specialist/clients/domain/usecases/get_specialist_client_profile_usecase.dart';
import 'package:fitness_day/features/specialist/clients/domain/usecases/get_upcoming_assessments_usecase.dart';
import 'package:fitness_day/features/specialist/clients/domain/usecases/get_previous_assessments_usecase.dart';
import 'package:fitness_day/features/specialist/clients/domain/usecases/get_client_progress_usecase.dart';
import 'package:fitness_day/features/specialist/clients/presentation/manager/specialist_clients_cubit.dart';
import 'package:fitness_day/features/specialist/clients/presentation/manager/specialist_client_profile_cubit.dart';
import 'package:fitness_day/features/specialist/clients/presentation/manager/client_assessments_cubit.dart';
import 'package:fitness_day/features/specialist/clients/presentation/manager/client_progress_cubit.dart';

// User Progress
import 'package:fitness_day/features/user/progress/data/datasources/user_progress_remote_datasource.dart';
import 'package:fitness_day/features/user/progress/data/repositories/user_progress_repository_impl.dart';
import 'package:fitness_day/features/user/progress/domain/repositories/user_progress_repository.dart';
import 'package:fitness_day/features/user/progress/domain/usecases/get_user_progress_usecase.dart';
import 'package:fitness_day/features/user/progress/presentation/manager/user_progress_cubit.dart';

// Specialist Daily Tasks
import 'package:fitness_day/features/specialist/tasks/data/datasources/specialist_daily_tasks_remote_datasource.dart';
import 'package:fitness_day/features/specialist/tasks/data/repositories/specialist_daily_tasks_repository_impl.dart';
import 'package:fitness_day/features/specialist/tasks/domain/repositories/specialist_daily_tasks_repository.dart';
import 'package:fitness_day/features/specialist/tasks/domain/usecases/get_specialist_daily_tasks_usecase.dart';
import 'package:fitness_day/features/specialist/tasks/presentation/manager/specialist_daily_tasks_cubit.dart';

// Specialist Visits & Assessment Details
import 'package:fitness_day/features/specialist/visits/data/datasources/specialist_visits_remote_datasource.dart';
import 'package:fitness_day/features/specialist/visits/data/repositories/specialist_visits_repository_impl.dart';
import 'package:fitness_day/features/specialist/visits/domain/repositories/specialist_visits_repository.dart';
import 'package:fitness_day/features/specialist/visits/domain/usecases/get_assessment_history_usecase.dart';
import 'package:fitness_day/features/specialist/visits/domain/usecases/get_visit_data_usecase.dart';
import 'package:fitness_day/features/specialist/visits/domain/usecases/get_health_report_usecase.dart';
import 'package:fitness_day/features/specialist/visits/domain/usecases/get_custom_plan_usecase.dart';
import 'package:fitness_day/features/specialist/visits/domain/usecases/start_visit_usecase.dart';
import 'package:fitness_day/features/specialist/visits/domain/usecases/update_goal_usecase.dart';
import 'package:fitness_day/features/specialist/visits/domain/usecases/update_health_report_usecase.dart';
import 'package:fitness_day/features/specialist/visits/domain/usecases/update_custom_plan_usecase.dart';
import 'package:fitness_day/features/specialist/visits/presentation/manager/visits_cubit.dart';
import 'package:fitness_day/features/specialist/visits/presentation/manager/visit_details_cubit.dart';
import 'package:fitness_day/features/specialist/notifications/data/datasources/specialist_notifications_remote_datasource.dart';
import 'package:fitness_day/features/specialist/notifications/data/repositories/specialist_notifications_repository_impl.dart';
import 'package:fitness_day/features/specialist/notifications/domain/repositories/specialist_notifications_repository.dart';
import 'package:fitness_day/features/specialist/notifications/domain/usecases/get_specialist_notifications_usecase.dart';
import 'package:fitness_day/features/specialist/notifications/domain/usecases/toggle_notification_read_usecase.dart';

// User Notifications
import 'package:fitness_day/features/user/notifications/data/datasources/user_notifications_remote_datasource.dart';
import 'package:fitness_day/features/user/notifications/data/repositories/user_notifications_repository_impl.dart';
import 'package:fitness_day/features/user/notifications/domain/repositories/user_notifications_repository.dart';
import 'package:fitness_day/features/user/notifications/domain/usecases/get_user_notifications_usecase.dart';
import 'package:fitness_day/features/user/notifications/domain/usecases/toggle_user_notification_read_usecase.dart';
import 'package:fitness_day/features/user/notifications/presentation/manager/user_notifications_cubit.dart';

// User Profile
import 'package:fitness_day/features/user/profile/data/datasources/user_profile_remote_datasource.dart';
import 'package:fitness_day/features/user/profile/data/repositories/user_profile_repository_impl.dart';
import 'package:fitness_day/features/user/profile/domain/repositories/user_profile_repository.dart';
import 'package:fitness_day/features/user/profile/domain/usecases/get_user_profile_usecase.dart';
import 'package:fitness_day/features/user/profile/domain/usecases/update_user_profile_usecase.dart';
import 'package:fitness_day/features/user/profile/domain/usecases/toggle_user_notifications_usecase.dart';
import 'package:fitness_day/features/user/profile/domain/usecases/update_user_lang_usecase.dart';
import 'package:fitness_day/features/user/profile/domain/usecases/change_password_usecase.dart';
import 'package:fitness_day/features/user/profile/domain/usecases/request_change_phone_otp_usecase.dart';
import 'package:fitness_day/features/user/profile/domain/usecases/verify_change_phone_otp_usecase.dart';
import 'package:fitness_day/features/user/profile/domain/usecases/user_signout_usecase.dart';
import 'package:fitness_day/features/user/profile/domain/usecases/delete_account_usecase.dart';
import 'package:fitness_day/features/user/profile/presentation/manager/user_profile_cubit.dart';
import 'package:fitness_day/features/specialist/notifications/presentation/manager/specialist_notifications_cubit.dart';

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
import 'package:fitness_day/features/user/visits/domain/usecases/get_activity_details_usecase.dart';
import 'package:fitness_day/features/user/visits/domain/usecases/update_meal_completion_usecase.dart';
import 'package:fitness_day/features/user/visits/presentation/manager/diet_plan_cubit.dart';
import 'package:fitness_day/features/user/visits/presentation/manager/meal_details_cubit.dart';
import 'package:fitness_day/features/user/visits/presentation/manager/activity_details_cubit.dart';
import 'package:fitness_day/features/user/visits/presentation/manager/assessments_cubit.dart';
import 'package:fitness_day/features/user/visits/presentation/manager/change_assessment_cubit.dart';
import 'package:fitness_day/features/user/visits/presentation/manager/assessment_details_cubit.dart';

// User Workouts
import 'package:fitness_day/features/user/workout/data/datasources/workout_remote_datasource.dart';
import 'package:fitness_day/features/user/workout/data/repositories/workout_repository_impl.dart';
import 'package:fitness_day/features/user/workout/domain/repositories/workout_repository.dart';
import 'package:fitness_day/features/user/workout/domain/usecases/get_workout_plan_usecase.dart';
import 'package:fitness_day/features/user/workout/domain/usecases/get_workout_details_usecase.dart';
import 'package:fitness_day/features/user/workout/domain/usecases/complete_workout_set_usecase.dart';
import 'package:fitness_day/features/user/workout/presentation/manager/workout_plan_cubit.dart';
import 'package:fitness_day/features/user/workout/presentation/manager/workout_details_cubit.dart';

// User Home
import 'package:fitness_day/features/user/user_home/data/datasources/user_home_remote_datasource.dart';

// Market / Store
import 'package:fitness_day/features/user/market/data/datasources/market_remote_datasource.dart';
import 'package:fitness_day/features/user/market/data/repositories/market_repository_impl.dart';
import 'package:fitness_day/features/user/market/domain/repositories/market_repository.dart';
import 'package:fitness_day/features/user/market/domain/usecases/get_store_home_usecase.dart';
import 'package:fitness_day/features/user/market/domain/usecases/get_products_usecase.dart';
import 'package:fitness_day/features/user/market/domain/usecases/get_product_by_id_usecase.dart';
import 'package:fitness_day/features/user/market/domain/usecases/get_plans_usecase.dart';
import 'package:fitness_day/features/user/market/domain/usecases/get_favorites_usecase.dart';
import 'package:fitness_day/features/user/market/presentation/manager/favorites_cubit.dart';
import 'package:fitness_day/features/user/market/domain/usecases/get_plan_by_id_usecase.dart';
import 'package:fitness_day/features/user/market/domain/usecases/toggle_favorite_usecase.dart';
import 'package:fitness_day/features/user/market/presentation/manager/market_home_cubit.dart';
import 'package:fitness_day/features/user/market/presentation/manager/product_details_cubit.dart';
import 'package:fitness_day/features/user/market/presentation/manager/plans_cubit.dart';
import 'package:fitness_day/features/user/market/presentation/manager/plan_details_cubit.dart';
import 'package:fitness_day/features/user/market/data/datasources/address_remote_datasource.dart';
import 'package:fitness_day/features/user/market/data/repositories/address_repository_impl.dart';
import 'package:fitness_day/features/user/market/domain/repositories/address_repository.dart';
import 'package:fitness_day/features/user/market/domain/usecases/get_addresses_usecase.dart';
import 'package:fitness_day/features/user/market/domain/usecases/create_address_usecase.dart';
import 'package:fitness_day/features/user/market/domain/usecases/update_address_usecase.dart';
import 'package:fitness_day/features/user/market/domain/usecases/delete_address_usecase.dart';
import 'package:fitness_day/features/user/market/presentation/manager/addresses_cubit.dart';
import 'package:fitness_day/features/user/market/data/datasources/cart_remote_datasource.dart';
import 'package:fitness_day/features/user/market/data/repositories/cart_repository_impl.dart';
import 'package:fitness_day/features/user/market/domain/repositories/cart_repository.dart';
import 'package:fitness_day/features/user/market/domain/usecases/get_cart_usecase.dart';
import 'package:fitness_day/features/user/market/domain/usecases/add_to_cart_usecase.dart';
import 'package:fitness_day/features/user/market/domain/usecases/update_cart_quantity_usecase.dart';
import 'package:fitness_day/features/user/market/domain/usecases/remove_cart_item_usecase.dart';
import 'package:fitness_day/features/user/market/presentation/manager/cart_cubit.dart';
import 'package:fitness_day/features/user/market/data/datasources/checkout_remote_datasource.dart';
import 'package:fitness_day/features/user/market/data/repositories/checkout_repository_impl.dart';
import 'package:fitness_day/features/user/market/domain/repositories/checkout_repository.dart';
import 'package:fitness_day/features/user/market/domain/usecases/get_branches_usecase.dart';
import 'package:fitness_day/features/user/market/domain/usecases/checkout_usecase.dart';
import 'package:fitness_day/features/user/market/domain/usecases/apply_coupon_usecase.dart';
import 'package:fitness_day/features/user/market/domain/usecases/edit_delivery_usecase.dart';
import 'package:fitness_day/features/user/market/presentation/manager/checkout_cubit.dart';
import 'package:fitness_day/features/user/market/domain/usecases/get_orders_usecase.dart';
import 'package:fitness_day/features/user/market/presentation/manager/orders_cubit.dart';
import 'package:fitness_day/features/user/user_home/data/repositories/user_home_repository_impl.dart';
import 'package:fitness_day/features/user/user_home/domain/repositories/user_home_repository.dart';
import 'package:fitness_day/features/user/user_home/domain/usecases/user_home_usecases.dart';
import 'package:fitness_day/features/user/user_home/presentation/manager/user_home_cubit.dart';
import 'package:fitness_day/features/user/user_home/presentation/manager/saved_articles_cubit.dart';
import 'package:fitness_day/features/user/user_home/presentation/manager/articles_list_cubit.dart';
import 'package:fitness_day/core/services/health_service.dart';

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
    () => AuthRemoteDataSourceImpl(getIt<ApiService>()),
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

  getIt.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(getIt<AuthRepository>()),
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

  getIt.registerLazySingleton<GetActivityDetailsUseCase>(
    () => GetActivityDetailsUseCase(getIt<VisitsRepository>()),
  );

  getIt.registerLazySingleton<UpdateMealCompletionUseCase>(
    () => UpdateMealCompletionUseCase(getIt<VisitsRepository>()),
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
    () => AuthCubit(
      loginUseCase: getIt<LoginUseCase>(),
      logoutUseCase: getIt<LogoutUseCase>(),
      secureCache: getIt<SecureCache>(),
      appCache: getIt<AppCache>(),
    ),
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
  
  getIt.registerFactory<AssessmentsCubit>(
    () => AssessmentsCubit(getIt<VisitsRepository>()),
  );
  
  getIt.registerFactory<ChangeAssessmentCubit>(
    () => ChangeAssessmentCubit(getIt<VisitsRepository>()),
  );

  getIt.registerFactory<AssessmentDetailsCubit>(
    () => AssessmentDetailsCubit(getIt<VisitsRepository>()),
  );

  getIt.registerFactory<MealDetailsCubit>(
    () => MealDetailsCubit(
      getMealDetailsUseCase: getIt<GetMealDetailsUseCase>(),
      updateMealCompletionUseCase: getIt<UpdateMealCompletionUseCase>(),
    ),
  );

  getIt.registerFactory<ActivityDetailsCubit>(
    () => ActivityDetailsCubit(
      getActivityDetailsUseCase: getIt<GetActivityDetailsUseCase>(),
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

  // User Home
  getIt.registerLazySingleton<UserHomeRemoteDataSource>(
    () => UserHomeRemoteDataSourceImpl(getIt<ApiService>()),
  );

  getIt.registerLazySingleton<UserHomeRepository>(
    () => UserHomeRepositoryImpl(getIt<UserHomeRemoteDataSource>()),
  );

  getIt.registerLazySingleton<GetUserHomeDataUseCase>(
    () => GetUserHomeDataUseCase(getIt<UserHomeRepository>()),
  );

  getIt.registerLazySingleton<GetArticlesUseCase>(
    () => GetArticlesUseCase(getIt<UserHomeRepository>()),
  );
  getIt.registerLazySingleton<ToggleSaveArticleUseCase>(
    () => ToggleSaveArticleUseCase(getIt<UserHomeRepository>()),
  );
  getIt.registerLazySingleton<GetSavedArticlesUseCase>(
    () => GetSavedArticlesUseCase(getIt<UserHomeRepository>()),
  );

  getIt.registerLazySingleton<GetArticleByIdUseCase>(
    () => GetArticleByIdUseCase(getIt<UserHomeRepository>()),
  );

  getIt.registerFactory<UserHomeCubit>(
    () => UserHomeCubit(
      getUserHomeDataUseCase: getIt<GetUserHomeDataUseCase>(),
      getArticlesUseCase: getIt<GetArticlesUseCase>(),
    ),
  );

  getIt.registerFactory<SavedArticlesCubit>(
    () => SavedArticlesCubit(
      getSavedArticlesUseCase: getIt<GetSavedArticlesUseCase>(),
      toggleSaveArticleUseCase: getIt<ToggleSaveArticleUseCase>(),
    ),
  );

  getIt.registerFactory<ArticlesListCubit>(
    () => ArticlesListCubit(
      getArticlesUseCase: getIt<GetArticlesUseCase>(),
    ),
  );

  // Health & Activity tracking
  getIt.registerLazySingleton<FitnessHealthService>(
    () => FitnessHealthService(),
  );

  // Market / Store
  getIt.registerLazySingleton<MarketRemoteDataSource>(
    () => MarketRemoteDataSourceImpl(getIt<ApiService>()),
  );
  getIt.registerLazySingleton<MarketRepository>(
    () => MarketRepositoryImpl(getIt<MarketRemoteDataSource>()),
  );
  getIt.registerLazySingleton<GetStoreHomeUseCase>(
    () => GetStoreHomeUseCase(getIt<MarketRepository>()),
  );
  getIt.registerLazySingleton<GetProductsUseCase>(
    () => GetProductsUseCase(getIt<MarketRepository>()),
  );
  getIt.registerLazySingleton<GetProductByIdUseCase>(
    () => GetProductByIdUseCase(getIt<MarketRepository>()),
  );
  getIt.registerLazySingleton<GetPlansUseCase>(
    () => GetPlansUseCase(getIt<MarketRepository>()),
  );
  getIt.registerLazySingleton<GetPlanByIdUseCase>(
    () => GetPlanByIdUseCase(getIt<MarketRepository>()),
  );
  getIt.registerLazySingleton<ToggleFavoriteUseCase>(
    () => ToggleFavoriteUseCase(getIt<MarketRepository>()),
  );
  getIt.registerFactory<MarketHomeCubit>(
    () => MarketHomeCubit(getIt<GetStoreHomeUseCase>()),
  );
  getIt.registerFactory<ProductDetailsCubit>(
    () => ProductDetailsCubit(
      getIt<GetProductByIdUseCase>(),
      getIt<ToggleFavoriteUseCase>(),
    ),
  );
  getIt.registerLazySingleton<GetFavoritesUseCase>(
    () => GetFavoritesUseCase(getIt<MarketRepository>()),
  );
  getIt.registerFactory<FavoritesCubit>(
    () => FavoritesCubit(
      getIt<GetFavoritesUseCase>(),
      getIt<ToggleFavoriteUseCase>(),
    ),
  );
  getIt.registerFactory<PlansCubit>(
    () => PlansCubit(getIt<GetPlansUseCase>()),
  );
  getIt.registerFactory<PlanDetailsCubit>(
    () => PlanDetailsCubit(getIt<GetPlanByIdUseCase>()),
  );

  // Addresses (checkout / delivery)
  getIt.registerLazySingleton<AddressRemoteDataSource>(
    () => AddressRemoteDataSourceImpl(getIt<ApiService>()),
  );
  getIt.registerLazySingleton<AddressRepository>(
    () => AddressRepositoryImpl(getIt<AddressRemoteDataSource>()),
  );
  getIt.registerLazySingleton<GetAddressesUseCase>(
    () => GetAddressesUseCase(getIt<AddressRepository>()),
  );
  getIt.registerLazySingleton<CreateAddressUseCase>(
    () => CreateAddressUseCase(getIt<AddressRepository>()),
  );
  getIt.registerLazySingleton<UpdateAddressUseCase>(
    () => UpdateAddressUseCase(getIt<AddressRepository>()),
  );
  getIt.registerLazySingleton<DeleteAddressUseCase>(
    () => DeleteAddressUseCase(getIt<AddressRepository>()),
  );
  getIt.registerFactory<AddressesCubit>(
    () => AddressesCubit(
      getAddressesUseCase: getIt<GetAddressesUseCase>(),
      createAddressUseCase: getIt<CreateAddressUseCase>(),
      updateAddressUseCase: getIt<UpdateAddressUseCase>(),
      deleteAddressUseCase: getIt<DeleteAddressUseCase>(),
    ),
  );

  // Cart — CartCubit is a singleton so add-to-cart state (and the ✓ marker)
  // is shared across every store screen.
  getIt.registerLazySingleton<CartRemoteDataSource>(
    () => CartRemoteDataSourceImpl(getIt<ApiService>()),
  );
  getIt.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(getIt<CartRemoteDataSource>()),
  );
  getIt.registerLazySingleton<GetCartUseCase>(
    () => GetCartUseCase(getIt<CartRepository>()),
  );
  getIt.registerLazySingleton<AddToCartUseCase>(
    () => AddToCartUseCase(getIt<CartRepository>()),
  );
  getIt.registerLazySingleton<UpdateCartQuantityUseCase>(
    () => UpdateCartQuantityUseCase(getIt<CartRepository>()),
  );
  getIt.registerLazySingleton<RemoveCartItemUseCase>(
    () => RemoveCartItemUseCase(getIt<CartRepository>()),
  );
  getIt.registerLazySingleton<CartCubit>(
    () => CartCubit(
      getCartUseCase: getIt<GetCartUseCase>(),
      addToCartUseCase: getIt<AddToCartUseCase>(),
      updateQuantityUseCase: getIt<UpdateCartQuantityUseCase>(),
      removeItemUseCase: getIt<RemoveCartItemUseCase>(),
    ),
  );

  // Checkout — CheckoutCubit is a factory: one instance per checkout flow,
  // shared across the flow's pushed screens via BlocProvider.value.
  getIt.registerLazySingleton<CheckoutRemoteDataSource>(
    () => CheckoutRemoteDataSourceImpl(getIt<ApiService>()),
  );
  getIt.registerLazySingleton<CheckoutRepository>(
    () => CheckoutRepositoryImpl(getIt<CheckoutRemoteDataSource>()),
  );
  getIt.registerLazySingleton<GetBranchesUseCase>(
    () => GetBranchesUseCase(getIt<CheckoutRepository>()),
  );
  getIt.registerLazySingleton<CheckoutUseCase>(
    () => CheckoutUseCase(getIt<CheckoutRepository>()),
  );
  getIt.registerLazySingleton<ApplyCouponUseCase>(
    () => ApplyCouponUseCase(getIt<CheckoutRepository>()),
  );
  getIt.registerLazySingleton<EditDeliveryUseCase>(
    () => EditDeliveryUseCase(getIt<CheckoutRepository>()),
  );
  getIt.registerFactory<CheckoutCubit>(
    () => CheckoutCubit(
      checkoutUseCase: getIt<CheckoutUseCase>(),
      applyCouponUseCase: getIt<ApplyCouponUseCase>(),
      editDeliveryUseCase: getIt<EditDeliveryUseCase>(),
      getBranchesUseCase: getIt<GetBranchesUseCase>(),
    ),
  );
  getIt.registerLazySingleton<GetOrdersUseCase>(
    () => GetOrdersUseCase(getIt<CheckoutRepository>()),
  );
  getIt.registerFactory<OrdersCubit>(
    () => OrdersCubit(getIt<GetOrdersUseCase>()),
  );

  // Specialist Home
  getIt.registerLazySingleton<SpecialistHomeRemoteDataSource>(
    () => SpecialistHomeRemoteDataSourceImpl(getIt<ApiService>()),
  );
  getIt.registerLazySingleton<SpecialistHomeRepository>(
    () => SpecialistHomeRepositoryImpl(getIt<SpecialistHomeRemoteDataSource>()),
  );
  getIt.registerLazySingleton<GetSpecialistHomeDataUseCase>(
    () => GetSpecialistHomeDataUseCase(getIt<SpecialistHomeRepository>()),
  );
  getIt.registerFactory<SpecialistHomeCubit>(
    () => SpecialistHomeCubit(getIt<GetSpecialistHomeDataUseCase>()),
  );

  // Specialist Profile
  getIt.registerLazySingleton<SpecialistProfileRemoteDataSource>(
    () => SpecialistProfileRemoteDataSourceImpl(getIt<ApiService>()),
  );
  getIt.registerLazySingleton<SpecialistProfileRepository>(
    () => SpecialistProfileRepositoryImpl(getIt<SpecialistProfileRemoteDataSource>()),
  );
  getIt.registerLazySingleton<GetSpecialistProfileUseCase>(
    () => GetSpecialistProfileUseCase(getIt<SpecialistProfileRepository>()),
  );
  getIt.registerLazySingleton<UpdateSpecialistProfileUseCase>(
    () => UpdateSpecialistProfileUseCase(getIt<SpecialistProfileRepository>()),
  );
  getIt.registerFactory<SpecialistProfileCubit>(
    () => SpecialistProfileCubit(
      getIt<GetSpecialistProfileUseCase>(),
      getIt<UpdateSpecialistProfileUseCase>(),
    ),
  );

  // Specialist Clients
  getIt.registerLazySingleton<SpecialistClientsRemoteDataSource>(
    () => SpecialistClientsRemoteDataSourceImpl(getIt<ApiService>()),
  );
  getIt.registerLazySingleton<SpecialistClientsRepository>(
    () => SpecialistClientsRepositoryImpl(getIt<SpecialistClientsRemoteDataSource>()),
  );
  getIt.registerLazySingleton<GetSpecialistClientsUseCase>(
    () => GetSpecialistClientsUseCase(getIt<SpecialistClientsRepository>()),
  );
  getIt.registerLazySingleton<GetSpecialistClientProfileUseCase>(
    () => GetSpecialistClientProfileUseCase(getIt<SpecialistClientsRepository>()),
  );
  getIt.registerFactory<SpecialistClientsCubit>(
    () => SpecialistClientsCubit(getIt<GetSpecialistClientsUseCase>()),
  );
  getIt.registerFactory<SpecialistClientProfileCubit>(
    () => SpecialistClientProfileCubit(getIt<GetSpecialistClientProfileUseCase>()),
  );
  getIt.registerLazySingleton<GetUpcomingAssessmentsUseCase>(
    () => GetUpcomingAssessmentsUseCase(getIt<SpecialistClientsRepository>()),
  );
  getIt.registerLazySingleton<GetPreviousAssessmentsUseCase>(
    () => GetPreviousAssessmentsUseCase(getIt<SpecialistClientsRepository>()),
  );
  getIt.registerFactory<ClientAssessmentsCubit>(
    () => ClientAssessmentsCubit(
      getIt<GetUpcomingAssessmentsUseCase>(),
      getIt<GetPreviousAssessmentsUseCase>(),
    ),
  );
  getIt.registerLazySingleton<GetClientProgressUseCase>(
    () => GetClientProgressUseCase(getIt<SpecialistClientsRepository>()),
  );
  getIt.registerFactory<ClientProgressCubit>(
    () => ClientProgressCubit(getIt<GetClientProgressUseCase>()),
  );

  // User Progress
  getIt.registerLazySingleton<UserProgressRemoteDataSource>(
    () => UserProgressRemoteDataSourceImpl(getIt<ApiService>()),
  );
  getIt.registerLazySingleton<UserProgressRepository>(
    () => UserProgressRepositoryImpl(getIt<UserProgressRemoteDataSource>()),
  );
  getIt.registerLazySingleton<GetUserProgressUseCase>(
    () => GetUserProgressUseCase(getIt<UserProgressRepository>()),
  );
  getIt.registerFactory<UserProgressCubit>(
    () => UserProgressCubit(getIt<GetUserProgressUseCase>()),
  );

  // Specialist Daily Tasks
  getIt.registerLazySingleton<SpecialistDailyTasksRemoteDataSource>(
    () => SpecialistDailyTasksRemoteDataSourceImpl(getIt<ApiService>()),
  );
  getIt.registerLazySingleton<SpecialistDailyTasksRepository>(
    () => SpecialistDailyTasksRepositoryImpl(getIt<SpecialistDailyTasksRemoteDataSource>()),
  );
  getIt.registerLazySingleton<GetSpecialistDailyTasksUseCase>(
    () => GetSpecialistDailyTasksUseCase(getIt<SpecialistDailyTasksRepository>()),
  );
  getIt.registerFactory<SpecialistDailyTasksCubit>(
    () => SpecialistDailyTasksCubit(getIt<GetSpecialistDailyTasksUseCase>()),
  );

  // Specialist Visits & Details
  getIt.registerLazySingleton<SpecialistVisitsRemoteDataSource>(
    () => SpecialistVisitsRemoteDataSourceImpl(getIt<ApiService>()),
  );
  getIt.registerLazySingleton<SpecialistVisitsRepository>(
    () => SpecialistVisitsRepositoryImpl(getIt<SpecialistVisitsRemoteDataSource>()),
  );
  getIt.registerLazySingleton<GetAssessmentHistoryUseCase>(
    () => GetAssessmentHistoryUseCase(getIt<SpecialistVisitsRepository>()),
  );
  getIt.registerLazySingleton<GetVisitDataUseCase>(
    () => GetVisitDataUseCase(getIt<SpecialistVisitsRepository>()),
  );
  getIt.registerLazySingleton<GetHealthReportUseCase>(
    () => GetHealthReportUseCase(getIt<SpecialistVisitsRepository>()),
  );
  getIt.registerLazySingleton<GetCustomPlanUseCase>(
    () => GetCustomPlanUseCase(getIt<SpecialistVisitsRepository>()),
  );
  getIt.registerFactory<VisitsCubit>(
    () => VisitsCubit(getIt<GetAssessmentHistoryUseCase>()),
  );
  getIt.registerLazySingleton<StartVisitUseCase>(
    () => StartVisitUseCase(getIt<SpecialistVisitsRepository>()),
  );
  getIt.registerLazySingleton<UpdateGoalUseCase>(
    () => UpdateGoalUseCase(getIt<SpecialistVisitsRepository>()),
  );
  getIt.registerLazySingleton<UpdateHealthReportUseCase>(
    () => UpdateHealthReportUseCase(getIt<SpecialistVisitsRepository>()),
  );
  getIt.registerLazySingleton<UpdateCustomPlanUseCase>(
    () => UpdateCustomPlanUseCase(getIt<SpecialistVisitsRepository>()),
  );
  getIt.registerFactory<VisitDetailsCubit>(
    () => VisitDetailsCubit(
      getIt<GetVisitDataUseCase>(),
      getIt<GetHealthReportUseCase>(),
      getIt<GetCustomPlanUseCase>(),
      getIt<StartVisitUseCase>(),
      getIt<UpdateGoalUseCase>(),
      getIt<UpdateHealthReportUseCase>(),
      getIt<UpdateCustomPlanUseCase>(),
      getIt<SpecialistVisitsRepository>(),
    ),
  );

  // Specialist Notifications
  getIt.registerLazySingleton<SpecialistNotificationsRemoteDataSource>(
    () => SpecialistNotificationsRemoteDataSourceImpl(getIt<ApiService>()),
  );
  getIt.registerLazySingleton<SpecialistNotificationsRepository>(
    () => SpecialistNotificationsRepositoryImpl(getIt<SpecialistNotificationsRemoteDataSource>()),
  );
  getIt.registerLazySingleton<GetSpecialistNotificationsUseCase>(
    () => GetSpecialistNotificationsUseCase(getIt<SpecialistNotificationsRepository>()),
  );
  getIt.registerLazySingleton<ToggleNotificationReadUseCase>(
    () => ToggleNotificationReadUseCase(getIt<SpecialistNotificationsRepository>()),
  );
  getIt.registerFactory<SpecialistNotificationsCubit>(
    () => SpecialistNotificationsCubit(
      getIt<GetSpecialistNotificationsUseCase>(),
      getIt<ToggleNotificationReadUseCase>(),
    ),
  );

  // User Notifications
  getIt.registerLazySingleton<UserNotificationsRemoteDataSource>(
    () => UserNotificationsRemoteDataSourceImpl(getIt<ApiService>()),
  );
  getIt.registerLazySingleton<UserNotificationsRepository>(
    () => UserNotificationsRepositoryImpl(getIt<UserNotificationsRemoteDataSource>()),
  );
  getIt.registerLazySingleton<GetUserNotificationsUseCase>(
    () => GetUserNotificationsUseCase(getIt<UserNotificationsRepository>()),
  );
  getIt.registerLazySingleton<ToggleUserNotificationReadUseCase>(
    () => ToggleUserNotificationReadUseCase(getIt<UserNotificationsRepository>()),
  );
  getIt.registerFactory<UserNotificationsCubit>(
    () => UserNotificationsCubit(
      getIt<GetUserNotificationsUseCase>(),
      getIt<ToggleUserNotificationReadUseCase>(),
    ),
  );

  // User Profile
  getIt.registerLazySingleton<UserProfileRemoteDataSource>(
    () => UserProfileRemoteDataSourceImpl(getIt<ApiService>()),
  );
  getIt.registerLazySingleton<UserProfileRepository>(
    () => UserProfileRepositoryImpl(getIt<UserProfileRemoteDataSource>()),
  );
  getIt.registerLazySingleton<GetUserProfileUseCase>(
    () => GetUserProfileUseCase(getIt<UserProfileRepository>()),
  );
  getIt.registerLazySingleton<UpdateUserProfileUseCase>(
    () => UpdateUserProfileUseCase(getIt<UserProfileRepository>()),
  );
  getIt.registerLazySingleton<ToggleUserNotificationsUseCase>(
    () => ToggleUserNotificationsUseCase(getIt<UserProfileRepository>()),
  );
  getIt.registerLazySingleton<UpdateUserLangUseCase>(
    () => UpdateUserLangUseCase(getIt<UserProfileRepository>()),
  );
  getIt.registerLazySingleton<ChangePasswordUseCase>(
    () => ChangePasswordUseCase(getIt<UserProfileRepository>()),
  );
  getIt.registerLazySingleton<RequestChangePhoneOtpUseCase>(
    () => RequestChangePhoneOtpUseCase(getIt<UserProfileRepository>()),
  );
  getIt.registerLazySingleton<VerifyChangePhoneOtpUseCase>(
    () => VerifyChangePhoneOtpUseCase(getIt<UserProfileRepository>()),
  );
  getIt.registerLazySingleton<UserSignoutUseCase>(
    () => UserSignoutUseCase(getIt<UserProfileRepository>()),
  );
  getIt.registerLazySingleton<DeleteAccountUseCase>(
    () => DeleteAccountUseCase(getIt<UserProfileRepository>()),
  );
  // Lazy singleton (not factory): shared across UserProfilePage and
  // PersonalProfilePage so edits on one are reflected on the other without
  // an extra refetch, matching how UserSetupCubit is provided app-wide.
  getIt.registerLazySingleton<UserProfileCubit>(
    () => UserProfileCubit(
      getIt<GetUserProfileUseCase>(),
      getIt<UpdateUserProfileUseCase>(),
      getIt<ToggleUserNotificationsUseCase>(),
      getIt<UpdateUserLangUseCase>(),
      getIt<ChangePasswordUseCase>(),
      getIt<RequestChangePhoneOtpUseCase>(),
      getIt<VerifyChangePhoneOtpUseCase>(),
      getIt<UserSignoutUseCase>(),
      getIt<DeleteAccountUseCase>(),
      getIt<AppCache>(),
    ),
  );
}
