import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/profile/data/models/user_profile_model.dart';
import 'package:fitness_day/features/user/profile/domain/repositories/user_profile_repository.dart';

class UpdateUserLangUseCase {
  final UserProfileRepository repository;

  UpdateUserLangUseCase(this.repository);

  Future<ApiResult<UserProfileDataModel>> call(String lang) {
    return repository.updateLang(lang);
  }
}
