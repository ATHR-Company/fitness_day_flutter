import 'package:fitness_day/core/network/api_result.dart';
import '../entities/address_data.dart';

abstract class AddressRepository {
  Future<ApiResult<List<AddressData>>> getAddresses();
  Future<ApiResult<AddressData>> createAddress(AddressInput input);
  Future<ApiResult<AddressData>> updateAddress(String id, AddressInput input);
  Future<ApiResult<void>> deleteAddress(String id);
}
