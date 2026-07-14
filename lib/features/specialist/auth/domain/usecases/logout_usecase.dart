import 'package:dartz/dartz.dart';
import 'package:fitness_day/features/specialist/auth/domain/repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<Either<String, void>> call() async {
    return await repository.logout();
  }
}
