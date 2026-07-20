import 'package:fitness_day/core/network/api_result.dart';
import '../repositories/address_repository.dart';

class DeleteAddressUseCase {
  final AddressRepository repository;

  DeleteAddressUseCase(this.repository);

  Future<ApiResult<void>> call(String id) => repository.deleteAddress(id);
}
