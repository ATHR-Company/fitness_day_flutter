import 'package:dio/dio.dart';
import 'package:fitness_day/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:fitness_day/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:fitness_day/features/auth/domain/repositories/auth_repository.dart';
import 'package:fitness_day/features/auth/domain/usecases/login_usecase.dart';
import 'package:fitness_day/features/auth/presentation/manager/auth_cubit.dart';
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

  // TODO: Implement AppCache and SecureCache in lib/core/cache/
  // getIt.registerLazySingleton<AppCache>(
  //   () => AppCacheImpl(getIt<GetStorage>()),
  // );
  // getIt.registerLazySingleton<SecureCache>(
  //   () => SecureCacheImpl(getIt<FlutterSecureStorage>()),
  // );

  // ═════════════════════════════════════════════════
  //                   NETWORK
  // ═════════════════════════════════════════════════

  // TODO: Implement NetworkChecker in lib/core/network/
  // getIt.registerLazySingleton<NetworkChecker>(() => NetworkCheckerImpl());

  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: "https://api.example.com", // TODO: Move to ApiConstants
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

    // TODO: Add Interceptors once implemented
    // dio.interceptors.add(TokenInterceptor(...));
    // dio.interceptors.add(LanguageInterceptor(...));

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

  // TODO: Implement ApiService in lib/core/network/
  // getIt.registerLazySingleton<ApiService>(() => ApiService(getIt<Dio>()));

  // ═════════════════════════════════════════════════
  //                 DATA SOURCES
  // ═════════════════════════════════════════════════

  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(), // Inject ApiService once ready
  );

  // ═════════════════════════════════════════════════
  //                 REPOSITORIES
  // ═════════════════════════════════════════════════

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      getIt<AuthRemoteDataSource>(), // Using the registered DataSource
    ),
  );

  // ═════════════════════════════════════════════════
  //                 USE CASES
  // ═════════════════════════════════════════════════
  
  getIt.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(getIt<AuthRepository>()),
  );

  // ═════════════════════════════════════════════════
  //                    BLoCs
  // ═════════════════════════════════════════════════

  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(loginUseCase: getIt<LoginUseCase>()),
  );
}
