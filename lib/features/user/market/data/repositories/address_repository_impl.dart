import 'package:fitness_day/core/network/api_result.dart';
import '../../domain/entities/address_data.dart';
import '../../domain/repositories/address_repository.dart';
import '../datasources/address_remote_datasource.dart';
import 'package:fitness_day/core/errors/error_handler.dart';

class AddressRepositoryImpl implements AddressRepository {
  final AddressRemoteDataSource remoteDataSource;

  AddressRepositoryImpl(this.remoteDataSource);

  @override
  Future<ApiResult<List<AddressData>>> getAddresses() async {
    try {
      final models = await remoteDataSource.getAddresses();
      return Success(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<AddressData>> createAddress(AddressInput input) async {
    try {
      final model = await remoteDataSource.createAddress(input);
      return Success(model.toEntity());
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<AddressData>> updateAddress(
      String id, AddressInput input) async {
    try {
      final model = await remoteDataSource.updateAddress(id, input);
      return Success(model.toEntity());
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<void>> deleteAddress(String id) async {
    try {
      await remoteDataSource.deleteAddress(id);
      return const Success(null);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }
}
