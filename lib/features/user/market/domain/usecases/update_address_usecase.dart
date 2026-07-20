import 'package:fitness_day/core/network/api_result.dart';
import '../entities/address_data.dart';
import '../repositories/address_repository.dart';

class UpdateAddressUseCase {
  final AddressRepository repository;

  UpdateAddressUseCase(this.repository);

  Future<ApiResult<AddressData>> call(String id, AddressInput input) =>
      repository.updateAddress(id, input);
}
