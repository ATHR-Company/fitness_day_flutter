import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/auth/data/models/complete_personal_data_models.dart';
import 'package:fitness_day/features/user/auth/domain/repositories/user_auth_repository.dart';

class CompletePersonalDataUseCase {
  final UserAuthRepository _repository;

  CompletePersonalDataUseCase(this._repository);

  Future<ApiResult<CompletePersonalDataResponseModel>> call(CompletePersonalDataRequest request) {
    return _repository.completePersonalData(request);
  }
}
