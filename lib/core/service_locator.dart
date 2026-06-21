
// // Auth
// import 'package:fitness_day/features/auth/data/datasources/auth_remote_datasource.dart';
// import 'package:fitness_day/features/auth/domain/repositories/auth_repository.dart';
// import 'package:fitness_day/features/auth/data/repositories/auth_repository_impl.dart';
// import 'package:get_it/get_it.dart';


// final getIt = GetIt.instance;

// Future<void> init() async {
//   // ═════════════════════════════════════════════════
//   //                  EXTERNAL
//   // ═════════════════════════════════════════════════

//   await GetStorage.init();
//   getIt.registerLazySingleton(() => GetStorage());
//   getIt.registerLazySingleton(
//     () => const FlutterSecureStorage(
//       iOptions: IOSOptions(
//         accessibility: KeychainAccessibility.first_unlock_this_device,
//       ),
//       aOptions: AndroidOptions(),
//     ),
//   );

//   // ═════════════════════════════════════════════════
//   //                    CACHE
//   // ═════════════════════════════════════════════════

//   getIt.registerLazySingleton<AppCache>(
//     () => AppCacheImpl(getIt<GetStorage>()),
//   );
//   getIt.registerLazySingleton<SecureCache>(
//     () => SecureCacheImpl(getIt<FlutterSecureStorage>()),
//   );

//   // ═════════════════════════════════════════════════
//   //                   NETWORK
//   // ═════════════════════════════════════════════════

//   getIt.registerLazySingleton<NetworkChecker>(() => NetworkCheckerImpl());

//   getIt.registerLazySingleton<Dio>(() {
//     final dio = Dio(
//       BaseOptions(
//         baseUrl: ApiConstants.baseApiUrl,
//         connectTimeout: const Duration(seconds: 30),
//         receiveTimeout: const Duration(seconds: 30),
//         sendTimeout: const Duration(seconds: 30),
//         followRedirects: true,
//         maxRedirects: 3,
//         headers: {
//           'Accept': 'application/json',
//           'Content-Type': 'application/json',
//         },
//       ),
//     );

//     dio.interceptors.add(
//       TokenInterceptor(
//         secureCache: getIt<SecureCache>(),
//         appCache: getIt<AppCache>(),
//       ),
//     );

//     dio.interceptors.add(LanguageInterceptor(appCache: getIt<AppCache>()));

//     dio.interceptors.add(RetryInterceptor(dio: dio));

//     if (kDebugMode) {
//       dio.interceptors.add(
//         PrettyDioLogger(
//           requestHeader: true,
//           requestBody: true,
//           responseBody: true,
//           responseHeader: false,
//           error: true,
//           compact: true,
//           maxWidth: 90,
//         ),
//       );
//     }

//     return dio;
//   });
//   getIt.registerLazySingleton<ApiService>(() => ApiService(getIt<Dio>()));

//   // ═════════════════════════════════════════════════
//   //                   SERVICES
//   // ═════════════════════════════════════════════════

//   getIt.registerLazySingleton<SocialAuthService>(() => SocialAuthService());
//   getIt.registerLazySingleton<FilePickerService>(() => FilePickerService());
//   getIt.registerLazySingleton<LocalNotification>(() => LocalNotification(navigatorKey: navigatorKey) );
  
//   // ═════════════════════════════════════════════════
//   //                 DATA SOURCES
//   // ═════════════════════════════════════════════════

//   getIt.registerLazySingleton<AuthRemoteDataSource>(
//     () => AuthRemoteDataSourceImpl(apiService: getIt<ApiService>()),
//   );

//   getIt.registerLazySingleton<LocationRemoteDataSource>(
//     () => LocationRemoteDataSourceImpl(getIt<Dio>()),
//   );

//   // ═════════════════════════════════════════════════
//   //                 REPOSITORIES
//   // ═════════════════════════════════════════════════

//   getIt.registerLazySingleton<AuthRepository>(
//     () => AuthRepositoryImpl(
//       remoteDataSource: getIt<AuthRemoteDataSource>(),
//       networkChecker: getIt<NetworkChecker>(),
//       secureCache: getIt<SecureCache>(),
//       appCache: getIt<AppCache>(),
//     ),
//   );

//   getIt.registerLazySingleton<LocationRepository>(
//     () => LocationRepositoryImpl(
//       remoteDataSource: getIt<LocationRemoteDataSource>(),
//       networkChecker: getIt<NetworkChecker>(),
//     ),
//   );

//   // ═════════════════════════════════════════════════
//   //                    BLoCs
//   // ═════════════════════════════════════════════════

//   // Uncomment and configure once UseCases and Blocs are added to the project
//   // getIt.registerFactory(
//   //   () => RegisterBloc(
//   //     registerUseCase: getIt<RegisterUseCase>(),
//   //     socialLoginUseCase: getIt<SocialLoginUseCase>(),
//   //     authService: getIt<SocialAuthService>(),
//   //   ),
//   // );

// }
