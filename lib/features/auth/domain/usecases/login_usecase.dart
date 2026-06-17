import 'package:dartz/dartz.dart';
import 'package:fitness_day/features/auth/domain/entities/auth_entity.dart';
import 'package:fitness_day/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<String, AuthEntity>> call(String phone, String password) async {
    return await repository.login(phone, password);
  }
}
