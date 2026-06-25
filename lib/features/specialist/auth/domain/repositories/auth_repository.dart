import 'package:dartz/dartz.dart';
import 'package:fitness_day/features/specialist/auth/domain/entities/auth_entity.dart';

// Assuming we have a Failure class in core/errors, otherwise we'll use dynamic or string
abstract class AuthRepository {
  Future<Either<String, AuthEntity>> login(String phone, String password);
}
