import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/auth/data/models/user_lookups_model.dart';
import 'package:fitness_day/features/user/auth/domain/repositories/user_auth_repository.dart';

class GetUserLookupsUseCase {
  final UserAuthRepository _repository;

  GetUserLookupsUseCase(this._repository);

  Future<ApiResult<UserLookupsResponseModel>> call() {
    return _repository.getLookups();
  }
}
