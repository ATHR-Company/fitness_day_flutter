import 'package:fitness_day/core/network/api_result.dart';
import '../entities/address_data.dart';
import '../repositories/address_repository.dart';

class CreateAddressUseCase {
  final AddressRepository repository;

  CreateAddressUseCase(this.repository);

  Future<ApiResult<AddressData>> call(AddressInput input) =>
      repository.createAddress(input);
}
