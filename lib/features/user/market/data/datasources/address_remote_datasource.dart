import 'package:fitness_day/core/constant/api_endpoints.dart';
import 'package:fitness_day/core/network/api_service.dart';
import '../../domain/entities/address_data.dart';
import '../models/address_model.dart';

abstract class AddressRemoteDataSource {
  Future<List<AddressModel>> getAddresses();
  Future<AddressModel> createAddress(AddressInput input);
  Future<AddressModel> updateAddress(String id, AddressInput input);
  Future<void> deleteAddress(String id);
}

class AddressRemoteDataSourceImpl implements AddressRemoteDataSource {
  final ApiService apiService;

  AddressRemoteDataSourceImpl(this.apiService);

  @override
  Future<List<AddressModel>> getAddresses() async {
    final response = await apiService.get(ApiEndpoints.addresses);
    final List raw = response.data['data'] as List? ?? [];
    return raw
        .map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<AddressModel> createAddress(AddressInput input) async {
    final response = await apiService.post(
      ApiEndpoints.addresses,
      data: _bodyOf(input),
    );
    return AddressModel.fromJson(
      response.data['data'] as Map<String, dynamic>? ?? {},
    );
  }

  @override
  Future<AddressModel> updateAddress(String id, AddressInput input) async {
    final response = await apiService.patch(
      ApiEndpoints.addressById(id),
      data: _bodyOf(input),
    );
    return AddressModel.fromJson(
      response.data['data'] as Map<String, dynamic>? ?? {},
    );
  }

  @override
  Future<void> deleteAddress(String id) async {
    await apiService.delete(ApiEndpoints.addressById(id));
  }

  Map<String, dynamic> _bodyOf(AddressInput input) => {
        'title': input.title,
        'district': input.district,
        'street': input.street,
        'postalCode': input.postalCode,
        'lat': input.lat,
        'lng': input.lng,
        'isDefault': input.isDefault,
      };
}
