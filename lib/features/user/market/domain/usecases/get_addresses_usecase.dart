import 'package:fitness_day/core/network/api_result.dart';
import '../entities/address_data.dart';
import '../repositories/address_repository.dart';

class GetAddressesUseCase {
  final AddressRepository repository;

  GetAddressesUseCase(this.repository);

  Future<ApiResult<List<AddressData>>> call() => repository.getAddresses();
}
