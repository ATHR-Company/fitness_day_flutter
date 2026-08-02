import 'package:dartz/dartz.dart';
import 'package:fitness_day/core/errors/error_handler.dart';
import 'package:fitness_day/features/specialist/auth/data/datasources/auth_remote_datasource.dart';
import 'package:fitness_day/features/specialist/auth/domain/entities/auth_entity.dart';
import 'package:fitness_day/features/specialist/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<String, AuthEntity>> login(
    String phone,
    String password, {
    String? fcmToken,
    required String deviceType,
  }) async {
    try {
      final authModel = await remoteDataSource.login(
        phone,
        password,
        fcmToken: fcmToken,
        deviceType: deviceType,
      );
      return Right(authModel);
    } catch (e) {
      final failure = ErrorHandler.handle(e);
      return Left(failure.message);
    }
  }

  @override
  Future<Either<String, void>> logout() async {
    try {
      await remoteDataSource.logout();
      return const Right(null);
    } catch (e) {
      final failure = ErrorHandler.handle(e);
      return Left(failure.message);
    }
  }
}
